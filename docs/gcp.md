# Google Cloud Project

All the Cloud infrastructure is running on GCP. The choice of GCP was mostly made out of curiosity for the platform,
and a way for me to learn how GKE works.

## Setup

I didn't went too far on the basic setup of GCP, there is no root project or project delegation.
Since this is a small project there won't be a `develop`, `staging` and `production` projects, we'll just go straight to production.

Authentication is not done with SSO, it's just a single cli command away:

```sh
gcloud auth application-default login
```

This will save credentials under your `$HOME/.config/gcloud/...`, which terraform uses to manage GCP resources.
