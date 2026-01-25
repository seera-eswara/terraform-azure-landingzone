variable "cloud_mg_name" {
  description = "Name (ID) for the cloud management group"
  type        = string
  default     = "cloud"
}

variable "landingzones_mg_name" {
  description = "Name (ID) for the LandingZones management group"
  type        = string
  default     = "landingzones"
}

variable "cloud_owners" {
  description = "Principal IDs to assign Owner at cloud MG"
  type        = list(string)
  default     = []
}

variable "cloud_contributors" {
  description = "Principal IDs to assign Contributor at cloud MG"
  type        = list(string)
  default     = []
}

variable "landingzones_owners" {
  description = "Principal IDs to assign Owner at LandingZones MG"
  type        = list(string)
  default     = []
}

variable "landingzones_contributors" {
  description = "Principal IDs to assign Contributor at LandingZones MG"
  type        = list(string)
  default     = []
}
