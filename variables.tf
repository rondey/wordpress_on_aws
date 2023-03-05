variable "wp_version" {
  type        = string
  default     = ""
  description = "Wordpress version to use"
}

variable "db_version" {
  type    = string
  default = "8.0.28"
}

variable "db_name" {
  type    = string
  default = "wordpress"
}

variable "db_username" {
  type    = string
  default = "admin"
}

variable "db_password" {
  type    = string
  default = "SNgBNrPvrCaGvcPB37g4"
}

variable "db_cpu_type" {
  type    = string
  default = "db.t3.micro"
}

