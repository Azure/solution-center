ALL_FIELDS = {
    "G": "tags",
    "F": "keyFeatures",
    "P": "products",
    "T": "tech",
    "Q": "sampleQueries",
}

def get_fields(field_string: str) -> list:
    if not field_string:
        return ALL_FIELDS.values()
    
    fields = []
    for char in field_string:
        if char not in ALL_FIELDS: raise ValueError(f"Invalid field: {char}")
        fields.append(ALL_FIELDS[char])
    return fields