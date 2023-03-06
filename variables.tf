variable "wp_version" {
  type        = string
  default     = "latest"
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

variable "wp_cpu_type" {
  type    = string
  default = "t2.micro"
}

variable "arn_acm_certificate" {
  type    = string
  default = ""
}