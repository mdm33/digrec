# DiGreC

DiGreC is an application based on the PROIEL Annotator tool for displaying the Diachrony of Greek Case treebank, created by the Case in Diachrony project.

It contains new features for working specifically with Greek texts, including:

  - Parallel display of text in Greek and Roman alphabets using automatic transliteration
  - BetaCode search functionality for Greek texts
  - New command `proiel:text:clear` to clear all text data without resetting other data such as user profiles
  - Ability to use a single, combined lexicon and lemma list for Ancient and Modern Greek
  - Export of multiple texts to a single file
  - Semantic tagging using the DiGreC semantic tagging schema (view, edit, search, round-trip export and import)
  
The information-structure functionality, which is not used in the DiGreC treebank, has been removed from the user interface. The cross-linguistic alignment functionality has also been removed.

## Installing

DiGreC is a Ruby on Rails application. This version uses Ruby 3.3 and Rails 8.1, and works with MySQL.  For other database systems, it may be necessary to modify the SQL syntax used by Rails and by the application code.

The following instructions assume that you have a functional and up-to-date Ruby environment installed, and that you have already configured your database server.

### Step 1: Install dependencies

Make sure that bundler is installed and then install required dependencies:

```shell
$ bundle install
```

If you only intend to run the application in production mode, you can cut down the number of dependencies this way:

```shell
$ bundle install --without test development
```

### Step 2: Install external binaries

Install [graphviz](http://www.graphviz.org/) for dependency graph visualisations. Versions 2.26.3 and 2.30.1 are known to work, but more recent versions may also work.

`graphviz` must be compiled with SVG support. The recommended settings are the following:

    --with-fontconfig --with-freetype2 --with-pangocairo --with-rsvg

If you want to regenerate the finite-state transducer files, you will also need the [SFST toolkit](http://www.ims.uni-stuttgart.de/projekte/gramotron/SOFTWARE/SFST.html). This release is designed to work with version 1.3 of `SFST`.

### Step 3: Configure the database

Copy `config/database.yml.example` to `config/database.yml` and edit it to fit your setup.

Initialize a new database by running the following command:

```shell
$ bundle exec rake db:setup
```

Add an administrator account using the Rails console:

```shell
$ bundle exec rails c
Loading development environment (Rails 3.1.3)
>> User.create_confirmed_administrator! :login => "username", :first_name => "Foo", :last_name => "Bar", :email => "foo@bar"
```

You will be prompted to enter a password.

### Step 4: Generate an environment file

Generate an environment file by running

```shell
$ bundle exec rake generate_env
```

This generates a file called `.env` with run-time settings that are unique to this instance of the application. Inspect the contents of the file and edit it if necessary.

The `.env` file contains information that should not be made public. Make sure that other users on your system are unable to read `.env`. It is also not a good idea to add the file to a public version control system.

### Step 5: Precompile assets

For the production environment, assets should be precompiled:

```shell
RAILS_ENV=production bundle exec rake assets:precompile
```

If you run the application behind nginx or another webserver, you should ensure that the webserver serves the `public` directory. Otherwise, make sure that `RAILS_SERVE_STATIC_ASSETS` in `.env` is set to `true` so that Rails will serve this directory.

### Step 6: Perform additional initialization

Set up database entries for DiGreC-style semantic tagging:

```shell
bundle exec rake proiel:semantic_tags:setup
```

### Step 7: Start the server and worker

For development, run the server using

```shell
$ bundle exec rails s
```

This will run the site with your system's default web server.  *Make sure that you never run the system like this in production since it is possible to execute arbitrary commands on the server with web-console.*

For production environments, see your web server's documentation for how to run Rails applications.

## Editing locale files

Some key strings used by the application, such as the application's title, can
be modified by editing the files in `config/locales`.

## Testing

Tests are run using

```shell
$ bin/rake test
$ bin/rspec
```

To open a console, run

```shell
$ bin/rails c
```

## For Windows users

The easiest way to run DiGreC on Windows is using the Windows Subsystem for Linux.  By installing the Linux versions of Ruby and Rails, it should be possible to run DiGreC with little modification.

If the Windows Subsystem for Linux is not available, it may be possible to run DiGreC using native Windows versions of Ruby and Rails.  Many of the gems used in this application require native extensions that will need to be compiled for Windows during the installation process.  Some intervention may be needed in order for them to compile correctly; the exact steps involved will vary depending on your development environment, as these can differ quite widely.

## New in version 1.3.0

This version adds `new`/`create` paths to allow dynamic additions to an existing corpus via a web interface. When a new sentence is added, the option is given to attempt to tag tokens automatically for lemma and morphology. This feature looks only at similarity to existing corpus data and requires a large existing corpus to be effective. The output of automatic tagging should always be manually checked; if it is not manually checked, validation errors may be raised.

### Warning

The web interface should not be used to add new data in a production environment. This feature may cause URL references to change unexpectedly and/or invalidate objects held by other users. Note that the path `/sources/new` is not exposed in the user interface.

## New in version 1.4.0

This version has been updated to be compatible with Ruby 3.3, Rails 8.1, and MySQL 8.x. If you need compatibility with older versions, you can still use [version 1.3] (https://github.com/mdm33/digrec/tree/a48962dc5b5b7ebd869988ba5e7e46b909a419b9). Some changes are based on updates by Marius L. Jøhndal to the original PROIEL app, which we gratefully acknowledge. As part of the update, the auditing functionality has been removed; users who need to monitor access may be able to implement auditing directly through their database server.

## License

DiGreC is licensed under the terms of the GNU General Public License version 2. See the file `COPYING` for details.

PROIEL Annotator was written by Marius L. Jøhndal (University of Cambridge/University of Oslo), Dag Haug (University of Oslo) and Anders Nøklestad (University of Oslo).

DiGreC was adapted and developed by Morgan Macleod (Ulster University).