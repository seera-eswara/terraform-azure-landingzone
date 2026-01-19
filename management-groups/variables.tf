variable "platform_mg_name" {
  description = "Name (ID) for the Platform management group"
  type        = string
  default     = "platform"
}

variable "landingzones_mg_name" {
  description = "Name (ID) for the LandingZones management group"
  type        = string
  default     = "landingzones"
}

variable "platform_owners" {
  description = "Principal IDs to assign Owner at Platform MG"
  type        = list(string)
  default     = []
}

variable "platform_contributors" {
  description = "Principal IDs to assign Contributor at Platform MG"
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
