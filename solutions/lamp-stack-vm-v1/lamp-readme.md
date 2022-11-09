
# Deploy and Manage a LAMP Cluster on Azure

This deploys a [LAMP](https://en.wikipedia.org/wiki/LAMP_(software_bundle)) cluster on Azure. 

While you can use an [Azure free account](https://aka.ms/azure-free-phprefarch) to get started, depending on the configuration you choose you will likely be required to upgrade to a paid account.

## Predefined deployment options

Below are a list of pre-defined/restricted deployment options based on typical deployment scenarios (i.e. dev/test, production etc.) All configurations are fixed and you just need to pass your SSH public key to the template for logging in to the deployed VMs. Please note that the actual cost will be bigger with potentially autoscaled VMs, backups and network cost.

| Configuration | Estimated Cost | 
| --- | --- | 
| Dev/Test  | [link](https://azure.com/e/5f9752c934ab41799ae3264dd2ee57d1)|
| Small to Mid-Size | [link](https://azure.com/e/fd794268d0bf421aa17c626fb88f25bc)|
| Full Production Workload |[link](https://azure.com/e/e0f959b93ed84eb891dcc44f7883f5b5)|

## Stack Architecture

This template set deploys the following infrastructure core to your LAMP instance:

- Autoscaling web frontend layer (with nginx and PHP-FPM)
- Private Virtual Network for frontend instances
- Controller VM running cron and handling syslog for the autoscaling cluster
- [Azure Load balancer](https://azure.microsoft.com/en-us/services/load-balancer/) to balance across the autoscaling instances
- [Azure Database for MySQL](https://azure.microsoft.com/en-us/services/mysql/) or [Azure Database for PostgreSQL](https://azure.microsoft.com/en-us/services/postgresql/) or [Azure SQL Database](https://azure.microsoft.com/en-us/services/sql-database/)
- Dual [GlusterFS](https://www.gluster.org/) nodes or NFS for highly available access to LAMP files

# Next Steps

## Prepare deployed cluster for LAMP applications

You can install additional LAMP sites on your cluster, utilizing Nginx's virtual host feature. To manage your installed cluster, you'll first need to login to the LAMP cluster controller virtual machine. The directory you'll need to work out of is `/azlamp`. You will need privileged access which means that you'll either need to be root (superuser) or have *sudo* access.

## Configuring the controller for a specific LAMP application

### Connect via SSH

You can connect via SSH to the controller VM. From a Linux, macOS or Windows 10 client using the Windows Subsystem for Linux, you can connect to the controller's VM using SSH and the public IP or DNS name of the controller.

```sh
ssh user@ip-or-dns
```

The username can be configured with `sshUsername`; the default value is `azureadmin`. You'll be authenticating using your SSH private key, so no password is necessary for the SSH user.

### SSL Certs

The certificates for your LAMP application reside in `/azlamp/certs/yourdomain` or in this instance, `/azlamp/certs/wpsitename.mydomain.com`

```sh
mkdir /azlamp/certs/wpsitename.mydomain.com
```

Copy over the .crt and .key files over to `/azlamp/certs/wpsitename.mydomain.com`.
The file names should be changed to `nginx.crt` and `nginx.key` in order to be recognized by the configured nginx servers. Depending on your local environment, you may choose to use the utility *scp* or a tool like [WinSCP](https://winscp.net/eng/download.php) to copy these files over to the cluster controller virtual machine.

You can also generate a self-signed certificate, useful for testing only:

```sh
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /azlamp/certs/wpsitename.mydomain.com/nginx.key \
  -out /azlamp/certs/wpsitename.mydomain.com/nginx.crt \
  -subj "/C=US/ST=WA/L=Redmond/O=IT/CN=wpsitename.mydomain.com"
```

It's recommended that the certificate files be read-only to owner and that these files are owned by *www-data*:

```sh
chown www-data:www-data /azlamp/certs/wpsitename.mydomain.com/nginx.*
chmod 400 /azlamp/certs/wpsitename.mydomain.com/nginx.*
```

### Update Nginx configurations on all web frontend instances

Once the correspnding html/data/certs directories are configured, we need to reconfigure all Nginx services on web frontend instances, so that a virtual host is added for each newly added site, and old ones are removed. This is done by the `/azlamp/bin/update-vmss-config` hook (executed every minute on each and every VMSS instance using a cron job), which requires us to provide the commands to run on each VMSS instance. There's already a utility script installed for that, so it's easy to achieve this.

On the controller machine, look up the file `/azlamp/bin/update-vmss-config`. If you haven't modified that file, you'll see the following lines in the file:

```sh
        #1)
        #    . /azlamp/bin/utils.sh
        #    reset_all_sites_on_vmss true VMSS
        #;;
```

Remove all the leading `#` characters from these lines (to uncomment them) and save the file, then wait for about a minute. After that, your newly added sites should be available through the domain names specified/used as the directory names (Of course this assumes you set up your DNS records for your new site FQDNs so that their CNAME records point to the deployed LAMP cluster's load balancer DNS name, whis is of the form `lb-xyz123.an_azure_region.cloudapp.azure.com`).

If you make changes and add or remove websites at a later time, you'll already have the above lines commented out. Just create another `case` block, copying the 4 lines, but make sure to change the number so that it's one greater than the last VMSS config version number (you should be able to find that from the script). As an example, the final text would look like:

```sh
        1)
            . /azlamp/bin/utils.sh
            reset_all_sites_on_vmss true VMSS
        ;;
        2)
            . /azlamp/bin/utils.sh
            reset_all_sites_on_vmss true VMSS
        ;;
```

### Replicate PHP files

The last step is to let the `/azlamp/html` directory sync with `/var/www/html` in every VMSS instance. This should be done by running **this script on the controller machine**, as root:

```sh
/usr/local/bin/update_last_modified_time.azlamp.sh
```

Once this is run and after a minute, the `/var/www/html` directory on every VMSS instance should be the same as `/azlamp/html`, and the newly added sites should be available.

At this point, your app is setup to use in the LAMP cluster. If you'd like to install a separate LAMP application (WordPress or otherwise), you'll have to repeat the process listed here with a new domain for the new application.

## Code of Conduct

This project has adopted the [Microsoft Open Source Code of
Conduct](https://opensource.microsoft.com/codeofconduct/). For more
information see the [Code of Conduct
FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact
[opencode@microsoft.com](mailto:opencode@microsoft.com) with any
additional questions or comments.

## Legal Notices

Microsoft and any contributors grant you a license to the Microsoft
documentation and other content in this repository under the [Creative
Commons Attribution 4.0 International Public
License](https://creativecommons.org/licenses/by/4.0/legalcode), see
the [LICENSE](LICENSE) file, and grant you a license to any code in
the repository under the [MIT
License](https://opensource.org/licenses/MIT), see the
[LICENSE-CODE](LICENSE-CODE) file.

Microsoft, Windows, Microsoft Azure and/or other Microsoft products
and services referenced in the documentation may be either trademarks
or registered trademarks of Microsoft in the United States and/or
other countries. The licenses for this project do not grant you rights
to use any Microsoft names, logos, or trademarks. Microsoft's general
trademark guidelines can be found at
http://go.microsoft.com/fwlink/?LinkID=254653.

Privacy information can be found at https://privacy.microsoft.com/en-us/

Microsoft and any contributors reserve all others rights, whether
under their respective copyrights, patents, or trademarks, whether by
implication, estoppel or otherwise.