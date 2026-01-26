variable "cloudinfra_mg_name" {
  description = "Name (ID) for the Cloud Infra management group"
  type        = string
  default     = "cloudinfra"
}

variable "management_mg_name" {
  description = "Name (ID) for the Management management group"
  type        = string
  default     = "management"
}

variable "connectivity_mg_name" {
  description = "Name (ID) for the Connectivity management group"
  type        = string
  default     = "connectivity"
}

variable "identity_mg_name" {
  description = "Name (ID) for the Identity management group"
  type        = string
  default     = "identity"
}

variable "landingzones_mg_name" {
  description = "Name (ID) for the LandingZones management group"
  type        = string
  default     = "landingzones"
}

variable "corp_mg_name" {
  description = "Name (ID) for the Corp management group"
  type        = string
  default     = "corp"
}

variable "online_mg_name" {
  description = "Name (ID) for the Online management group"
  type        = string
  default     = "online"
}

variable "sandbox_mg_name" {
  description = "Name (ID) for the Sandbox management group"
  type        = string
  default     = "sandbox"
}

variable "cloudinfra_owners" {
  description = "Principal IDs to assign Owner at Cloud Infra MG"
  type        = list(string)
  default     = []
}

variable "cloudinfra_contributors" {
  description = "Principal IDs to assign Contributor at Cloud Infra MG"
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
