include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/log"
}

inputs = {
  log_retention_days  = 7
}
