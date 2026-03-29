output "repository_urls" {
  description = "Map of repository names to their URLs."
  value = {
    for key, repo in aws_ecr_repository.this : key => repo.repository_url
  }
}

output "repository_arns" {
  description = "Map of repository names to their ARNs."
  value = {
    for key, repo in aws_ecr_repository.this : key => repo.arn
  }
}
