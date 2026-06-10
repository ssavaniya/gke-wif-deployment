variable "project_id" {
  description = "The ID of the project in which to create resources"
  type        = string
  default     = "proserv-task02"
}

variable "region" {
  description = "The region in which to create resources"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The zone in which to create resources"
  type        = string
  default     = "us-central1-a"
}