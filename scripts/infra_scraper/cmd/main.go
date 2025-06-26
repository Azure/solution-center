package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"strings"
	"time"
)

type ExecDocs struct {
	Path string `json:"path"`
}

type DeploymentConfig struct {
	ExecDocs ExecDocs `json:"execDocs,omitempty"`
}

// Workload represents the structure of the JSON objects we're processing
type Workload struct {
	Id                string           `json:"id"`
	Title             string           `json:"title"`
	Description       string           `json:"description"`
	Author            string           `json:"author"`
	Source            string           `json:"source"`
	Tags              []string         `json:"tags"`
	KeyFeatures       []string         `json:"keyFeatures"`
	DeploymentOptions []string         `json:"deploymentOptions"`
	DeploymentConfig  DeploymentConfig `json:"deploymentConfig"`
	Products          []string         `json:"products"`
	SampleQueries     []string         `json:"sampleQueries"`
	SourceType        string           `json:"sourceType"`
	Tech              []string         `json:"tech"`
	Infrastructure    []string         `json:"infrastructure"`
}

// WorkloadTemp is a temporary struct used for custom JSON unmarshaling
type WorkloadTemp struct {
	Id                string           `json:"id"`
	Title             string           `json:"title"`
	Description       string           `json:"description"`
	Author            string           `json:"author"`
	Source            string           `json:"source"`
	Tags              json.RawMessage  `json:"tags"`
	KeyFeatures       json.RawMessage  `json:"keyFeatures"`
	DeploymentOptions json.RawMessage  `json:"deploymentOptions"`
	DeploymentConfig  DeploymentConfig `json:"deploymentConfig"`
	Products          json.RawMessage  `json:"products"`
	SampleQueries     json.RawMessage  `json:"sampleQueries"`
	SourceType        string           `json:"sourceType"`
	Tech              json.RawMessage  `json:"tech"`
	Infrastructure    json.RawMessage  `json:"infrastructure"`
}

// UnmarshalJSON implements custom JSON unmarshaling for Workload
func (w *Workload) UnmarshalJSON(data []byte) error {
	// Use a temporary struct to parse the JSON
	var temp WorkloadTemp
	if err := json.Unmarshal(data, &temp); err != nil {
		return err
	}

	// Copy the simple fields
	w.Id = temp.Id
	w.Title = temp.Title
	w.Description = temp.Description
	w.Author = temp.Author
	w.Source = temp.Source
	w.DeploymentConfig = temp.DeploymentConfig
	w.SourceType = temp.SourceType

	// Handle array fields that might be strings
	var err error

	w.Tags, err = parseStringOrArray(temp.Tags)
	if err != nil {
		w.Tags = []string{}
	}

	w.KeyFeatures, err = parseStringOrArray(temp.KeyFeatures)
	if err != nil {
		w.KeyFeatures = []string{}
	}

	w.DeploymentOptions, err = parseStringOrArray(temp.DeploymentOptions)
	if err != nil {
		w.DeploymentOptions = []string{}
	}

	w.Products, err = parseStringOrArray(temp.Products)
	if err != nil {
		w.Products = []string{}
	}

	w.SampleQueries, err = parseStringOrArray(temp.SampleQueries)
	if err != nil {
		w.SampleQueries = []string{}
	}

	w.Tech, err = parseStringOrArray(temp.Tech)
	if err != nil {
		w.Tech = []string{}
	}

	w.Infrastructure, err = parseStringOrArray(temp.Infrastructure)
	if err != nil {
		w.Infrastructure = []string{}
	}

	return nil
}

// parseStringOrArray handles fields that could be either a string or an array of strings
func parseStringOrArray(data json.RawMessage) ([]string, error) {
	if len(data) == 0 {
		return []string{}, nil
	}

	// Try parsing as an array first
	var strArray []string
	err := json.Unmarshal(data, &strArray)
	if err == nil {
		return strArray, nil
	}

	// If that fails, try parsing as a single string
	var str string
	err = json.Unmarshal(data, &str)
	if err != nil {
		return nil, err
	}

	// Return the string as a single-element array
	return []string{str}, nil
}

func main() {
	if len(os.Args) < 2 {
		log.Fatal("Please provide the path to the JSON file.")
	}
	filePath := os.Args[1]

	// Read the JSON file
	data, err := ioutil.ReadFile(filePath)
	if err != nil {
		log.Fatalf("Error reading file: %v", err)
	}

	// Parse the JSON data
	var objects []Workload
	err = json.Unmarshal(data, &objects)
	if err != nil {
		log.Fatalf("Error parsing JSON: %v", err)
	}

	// Process each object
	for i := range objects {
		// Pass a reference to the object so we can modify it
		downloadAndDeleteSourceRepo(&objects[i])
		// print the infrastructure details
		if len(objects[i].Infrastructure) > 0 {
			fmt.Printf("Infrastructure for object ID %s: %v\n", objects[i].Id, objects[i].Infrastructure)
		}
	}

	// write the updated objects back to a new json file
	outputFilePath := strings.TrimSuffix(filePath, ".json") + "_updated.json"

	// Delete file if it already exists
	if _, err := os.Stat(outputFilePath); err == nil {
		err = os.Remove(outputFilePath)
		if err != nil {
			log.Fatalf("Error removing existing output file: %v", err)
		}
	}
	outputFile, err := os.Create(outputFilePath)
	if err != nil {
		log.Fatalf("Error creating output file: %v", err)
	}
	defer outputFile.Close()

	encoder := json.NewEncoder(outputFile)
	encoder.SetIndent("", "  ")
	if err := encoder.Encode(objects); err != nil {
		log.Fatalf("Error writing to output file: %v", err)
	}
	fmt.Printf("Updated objects written to %s\n", outputFilePath)
}

// Example action to perform for each JSON object
func downloadAndDeleteSourceRepo(obj *Workload) {
	// Perform actions based on the object's data
	fmt.Printf("Processing object ID: %s, Title: %s, Source: %s\n", obj.Id, obj.Title, obj.Source)
	if strings.ToLower(obj.SourceType) == "execdocs" {
		return
	}
	source_split := strings.Split(obj.Source, "/")
	dir_name := source_split[len(source_split)-1]

	info, err := os.Stat(dir_name)
	if err == nil && info.IsDir() {
		fmt.Printf("Directory %s already exists, removing it.\n", dir_name)
		err = removeDirectory(dir_name, 3)
		if err != nil {
			log.Fatalf("Error removing existing directory: %v", err)
		}
	}

	repo := obj.Source + ".git"
	cmd := exec.Command("git", "clone", repo)
	err = cmd.Run()
	if err != nil {
		log.Printf("Error cloning repository: %v", err)
		return
	} else {
		fmt.Printf("Cloned repository: %s\n", repo)
		scrapeInfraDirectory(dir_name, obj)
	}

	time.Sleep(1 * time.Second)

	info, err = os.Stat(dir_name)
	if err == nil && info.IsDir() {
		fmt.Printf("Directory %s already exists, removing it.\n", dir_name)
		err = removeDirectory(dir_name, 3)
		if err != nil {
			log.Fatalf("Error removing existing directory: %v", err)
		}
	}
}

func removeDirectory(dirPath string, maxRetries int) error {
	var err error
	for i := 0; i < maxRetries; i++ {
		err = os.RemoveAll(dirPath)
		if err == nil {
			return nil
		}
		fmt.Printf("Attempt %d to remove directory failed, retrying in 1 second...\n", i+1)
		time.Sleep(1 * time.Second)
	}
	return err
}

func scrapeInfraDirectory(dir string, obj *Workload) {
	fmt.Printf("Scraping infrastructure directory: %s\n", dir)

	// Find all bicep files
	bicepFiles, err := findBicepFiles(dir)
	if err != nil {
		log.Printf("Error finding bicep files: %v", err)
		return
	}

	fmt.Printf("Found %d bicep files\n", len(bicepFiles))

	// Extract resource types from bicep files
	resourceTypes := extractResourceTypes(bicepFiles)

	// Remove duplicates and assign to the Workload
	obj.Infrastructure = uniqueStrings(resourceTypes)

	fmt.Printf("Found %d unique infrastructure resource types\n", len(obj.Infrastructure))
}

// findBicepFiles returns a list of all .bicep files in the given directory and its subdirectories
func findBicepFiles(rootDir string) ([]string, error) {
	var bicepFiles []string

	err := filepath.Walk(rootDir, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		if !info.IsDir() && strings.HasSuffix(strings.ToLower(info.Name()), ".bicep") {
			bicepFiles = append(bicepFiles, path)
		}
		return nil
	})

	return bicepFiles, err
}

// extractResourceTypes extracts Microsoft.* resource types from bicep files
func extractResourceTypes(bicepFiles []string) []string {
	var resourceTypes []string

	for _, file := range bicepFiles {
		content, err := ioutil.ReadFile(file)
		if err != nil {
			log.Printf("Error reading file %s: %v", file, err)
			continue
		}

		// Convert content to string
		text := string(content)

		// Look for resource declarations
		// Common patterns in bicep:
		// resource foo 'Microsoft.Something/resourceType@version' = { ... }
		// resource foo 'Microsoft.Something/resourceType' = { ... }
		resourceRegex := regexp.MustCompile(`resource\s+\w+\s+'(Microsoft\.[^/]+/[^@']+)(?:@[^']+)?'`)
		matches := resourceRegex.FindAllStringSubmatch(text, -1)

		for _, match := range matches {
			if len(match) >= 2 {
				resourceTypes = append(resourceTypes, match[1])
			}
		}
	}

	return resourceTypes
}

// uniqueStrings returns a new slice with duplicate strings removed
func uniqueStrings(strSlice []string) []string {
	keys := make(map[string]bool)
	uniqueList := []string{}

	for _, item := range strSlice {
		if _, value := keys[item]; !value {
			keys[item] = true
			uniqueList = append(uniqueList, item)
		}
	}

	return uniqueList
}
