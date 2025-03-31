# web-api
## 1. Create a basic domain resource entity class
(demo example: Credence::Document)
Choose the most important resource or entity related to your project idea
Pick an important resource that must be stored (e.g., File, Image, URL, etc.)
Do NOT pick 'User' accounts -- find a resource the user will interact with
Create the appropriate resource class for your project in the models/ folder
The #initialize method should create a new object of this resource
Write instance-level methods for each object of this resource:
#new_id method to create unique IDs for new objects
#to_json method to represent a resource object as json
#save method to save a new entity
Write class-level methods to search for resource:
::find method to find a specific entity by id or name
::all method to return ids for all entities of this resource
Store and retrieve resources as json text files in an app/db/store folder with filenames that look like: “[id].txt”

## 2. Create a Web API
Create the appropriate setup files (Gemfile, config.ru, and dotfiles, etc.) we discussed in class
Don’t forget to use .gitignore to ignore files in app/db/store/*
Create an appropriately named Roda-based API class in app/controllers/app.rb
Create a root route (/) that returns a basic json message
 (outside resources often check this route to see if your service is alive)
Create one POST route to create a new resource, given json information about it 
(e.g., POST /api/v1/[resources]), where [resources] is the name of your particular resource: files/pictures, etc.)
create one GET route to return details of a specific resource 
(e.g., GET /api/v1/[resources]/[id].json) to return jsonified resource data
create one GET route to return an ID list of all resources
(e.g., GET /api/v1/[resources] would return IDs of all resources as json)
Create a helpful README.md with instructions on how to use your API, including all routes
(keep this README up-to-date throughout the project)
Create a LICENSE file with terms of how your code can be adapted by others
(see choosealicense.com for help on picking a license)

## 3. Write Tests to confirm the API works
Create seed data and test file
Create a YAML seed data file for your data store in app/db/seeds/ 
Create a spec/api_spec.rb file to test your API
Use rack/test in your tests to call your API and check the last_response object
Create at least 4 tests:
HAPPY tests:
Test if the root route works
Test if creating a resource (POST method) works
Test if getting a single resource (GET) works
Test if getting a list of resources (GET) works
SAD tests:
Make sure that trying to GET a non-existent resource fails

## 4. Identify security issues your application currently faces
Think about vulnerabilities in confidentiality, integrity, authentication, authorization, non-repudiation, availability and performance
Think how a hacker might try to infiltrate the Web API
Consider how they might damage, delete, or steal data
Create Github Issues for these vulnerabilities
Create one issue for each vulnerability you think of
Detail what the vulnerability is (what is at risk)
Explain how it can be exploited (what an attacker might do to execute an attack)
We will try to resolve these vulnerabilities in future weeks
Add the bundler-audit gem to your Gemfile and run: bundle-audit check --update 
to confirm that your project does not include package vulnerabilities.
