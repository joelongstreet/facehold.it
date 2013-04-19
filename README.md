# FaceHold.it :facepunch:
Facehold.it is a simple service that provides facebook profile pictures for developers & designers to use as placeholders in their projects.

## Developers
Paste in `<img src='http://faceholdit.jit.su/pic' />` anywhere on your site to generate a placeholder image, or use it as a background-image. To prevent your browser from serving the same image, append a query string to the end of the resource call - `<img src='http://faceholdit.jit.su/pic?id=1' />`

## Designers
Refresh the page untill you see what you want, then copy the direct link or grab the photo for use in your design mockup. For extra fun, click on profiles to learn more about each person. Change the URL to generate more photos eg. http://faceholdit.jit.su/25

## Devving
* `npm install` to install dependencies.
* `S3_KEY=... S3_SECRET=... REDIS_PASS=... node runner.js` to run the application. If you'd like to use my s3 info and redis stuff just let me know.

## ToDo
* add/me route does not work, for some reason facebook is rejecting the access_token. Fucking facebook.

* Convert to Couch