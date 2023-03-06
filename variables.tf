variable "wp_version" {
  type        = string
  default     = "latest"
  description = "Wordpress version to use"
}

variable "db_version" {
  type    = string
  default = "8.0.28"
  description = "MySQL database version"
}

variable "db_name" {
  type    = string
  default = "wordpress"
  description = "Name of the database"
}

variable "db_username" {
  type    = string
  default = "admin"
  description = "Username of the database"
}

variable "db_password" {
  type    = string
  #default = "SNgBNrPvrCaGvcPB37g4"
  description = "Password of the database"
}

variable "db_cpu_type" {
  type    = string
  default = "db.t3.micro"
  description = "Instance type of the database"
}

variable "wp_cpu_type" {
  type    = string
  default = "t2.micro"
  description = "Instance type of the Wordpress instance"
}

variable "min_instances_size" {
  type = number
  default = 1
  description = "Minimum number of Wordpress instances running"
}

variable "max_instances_size" {
  type = number
  default = 10
  description = "Maximum number of Wordpress instances running"
}

variable "site_user" {
  type    = string
  default = "user"
  description = "Username to login on Wordpress"
}

variable "site_password" {
  type    = string
  default = "bitnami"
  description = "Password to login on Wordpress"
}

variable "site_email" {
  type    = string
  default = "user@example.com"
  description = "Email of the Wordpress administrator"
}

variable "site_name" {
  type    = string
  default = "FirstName"
  description = "Name of the Wordpress administrator"
}

variable "site_surname" {
  type    = string
  default = "LastName"
  description = "Surname of the Wordpress administrator"
}

variable "site_blog" {
  type    = string
  default = "User's blog"
  description = "Name of the Wordpress blog"
}

variable "arn_acm_certificate" {
  type    = string
  default = ""
  description = "HTTPS ARN ACM certificates"
}