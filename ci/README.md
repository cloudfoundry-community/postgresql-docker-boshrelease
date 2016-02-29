Pipeline to build images
========================

Update pipeline
---------------

```
fly -t oss sp -p $(basename $(pwd)) -c ci/pipeline.yml -l ci/credentials.yml
```
