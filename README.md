## Installazione

1. `terraform init`
1. `terraform apply`

Attenzione: per avere HTTP abilitato, si assume che sia già stato richiesto il certificato ACM. È necessario decommentare in "ec2.tf" il listener HTTPS e definire la variabile "arn_acm_certificate".
