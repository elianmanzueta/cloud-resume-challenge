#!/bin/bash

terraform apply -auto-approve

NEW_DISTRIBUTION_ID=$(terraform output distribution_id)
NEW_S3_BUCKET=$(terraform output bucket_id)

gh secret set DISTRIBUTION_ID -b"$NEW_DISTRIBUTION_ID"
gh secret set S3_BUCKET -b"$NEW_S3_BUCKET"
