# S5 (Super Simple Serverless Stock Searcher)

## Why?
I wanted stock alerts for some items on a site that didn't have
them built in and I needed to brush up on my node/GCP infrastructure
chops.

## What?
There's a GCP cloud function in `app.js` that scrapes a site and looks for 
"in stock" or "out of stock" text within a given element id. If it finds it
it'll fire off an email reporting the success. 

Cloud function is triggered by a pubsub message with an attribute of the url
to scrape, base64 encoded:
```js
{
    "url": "BASE64URL",
}
```

This all fits comfortably in the GCP free forever tier.

## How?
Makefile automates *almost* the entire deployment via terraform and gcloud
command line tool.

0. Create a GCP account if you don't have one and a new, blank project
   1. Create a service account with `Project Editor` role and download the service account key as a json file.      
   2. Place it into this directory as `service_account.json`
1. Install deps:
   1. `node` and `terraform` via your fav package manager
   2. `gcloud` CLI [from here](https://cloud.google.com/sdk/docs/install)
      1. `gcloud auth login` to your GCP account
2. Copy `.env.sample` file to just `.env` and add your own values for each. Leave GCP zone/region the same to stay in the free tier.
3. `make install test` to make sure everything's happy
4. `make deploy` to deploy everything to your GCP project

## ToDo:
- Use GCP secret manager instead of env vars for SendGrid key. Secret Manager isn't in the free tier yet though.
- Make the function more flexible to allow scraping more sites.
- Move cloud function deploy to terraform rather than using gcloud CLI. This involves a few more steps because you need to package the function files yourself and put them in a storage bucket. 
- Move the cloud scheduler config out of terraform so you can manage multiple schedule checks running at once. You can do this manually atm via `gcloud` or the console but would be nice to have a tool for it.
- The email body is pretty basic, would be good to improve that.
- Cloud Run seems to be the new hotness so move it to there next time.