Maintenance tasks
=================

A list of all the maintenance tasks can be obtained by running the command `rake -T proiel`:

    $ rake -T proiel
    rake proiel:dictionary:import             # Import a PROIEL dictionary.
    rake proiel:history:prune:attribute       # Prune an attribute from history.
    rake proiel:morphology:force_manual_tags  # Force manual morphological rules.
    ...

A number of these tasks are explained in more detail below.

`proiel:morphology:reassign`
----------------------------

This task is used to change all occurrences of a particular value of a morphological
field to another value in the +tokens+ table, i.e. to change the
+source_morphology+ field. For example

    $ rake proiel:morphology:reassign FIELD=voice FROM=o TO=p
    ...

will replace the value `p` with `o` in the `voice` field. No further
restrictions on the operation can be given, so the task is only useful
for keeping tag set and database synchronised.

`proiel:morphology:force_manual_tags`
-------------------------------------

This task will apply the morphology set out in manually crafted morpholgical rules
to all tokens that match the criteria in the rules for given sources. This can be
used to overwrite bad annotations once the manually crafted morphological rules are
deemed to be entirely correct.

    $ rake proiel:morphology:force_manual_tags SOURCES=perseus-vulgate-synth
     INFO manual-tagger: Working on source perseus-vulgate-synth...
    ERROR manual-tagger: Token 251733 (sentence 12871) 'in': Tagged with closed class morphology but not found in definition.
    ERROR manual-tagger: Token 251782 (sentence 12878) 'quia': Tagged with closed class morphology but not found in definition.

`proiel:history:prune:attribute`
--------------------------------

This task is used to completely remove all entries that refer to particular
attribute from the history. This is occasionally useful when changing the database
schema when columns are removed and the data lost by the change is of no future value.

Example:

    $ rake proiel:history:prune:attribute MODEL=Token ATTRIBUTE=morphtag_source
    Removing attribute Token.morphtag_source from audit 17695
    Removing attribute Token.morphtag_source from audit 17696
    Removing attribute Token.morphtag_source from audit 17698
    Removing attribute Token.morphtag_source from audit 17701
    Removing attribute Token.morphtag_source from audit 17702
    Removing attribute Token.morphtag_source from audit 17703
    ...

`proiel:validate`
-----------------

This task validates the entire database, first using model validations for each, then
using secondary constraints that have not been implemented in the models. Some of these
are designed to be auto-correcting, e.g. orphaned lemmata are cleaned up by this task.

The task is intended to be run whenever the annotation scheme is modified to ensure that
all annotation remains valid.

`proiel:dependency_alignments:import`
-------------------------------------

This task can be used for mass-import of dependency alignment. The data file should be
a comma-separated file on the following format:

    ALIGN,12345,67890
    TERMINATE,12346,2

This will align the dependency subgraph for token 67890 (in the secondary source)
with the dependency subgraph for token 12345 (in the primary source). It will then
terminate the dependency subgraph for token 12346 (in the primary source) with
respect to the secondary source with ID 2.

`proiel:semantic_tags:import` and `proiel:semantic_tags:export`
---------------------------------------------------------------

These tasks can be used for mass-import and -export of semantic tags. The data file is 
expected to be a comma-separated file with the following fields:

  * Taggable type (string, either `Token` or `Lemma`)
  * Taggable ID (integer)
  * Attribute tag (string)
  * Attribute value tag (string)

All attributes and attribute values must already have been defined; so must any
referred token or lemmma.

Example:

    $ rake proiel:semantic_tags:export FILE=tags.csv
    $ cat tags.csv
    Token,266690,animacy,-
    Lemma,2256,animacy,+
    ...
    $ rake proiel:semantic_tags:import FILE=tags.csv

`proiel:text:export`
--------------------

This task exports texts and per-sentence annotation to a number of different formats.
The source to export is identified using the variable `ID`. If not provided, all available
texts will be exported. The variable `FORMAT` serves to select which export format to
use. By default, the PROIEL XML format is used. Other alternatives are `maltxml` and
`tigerxml`.

`MODE` is by default `all`, which will export all available data. Alternatively, the
setting `reviewed` will only export sentences that have been reviewed. Finally, the
variable `DIRECTORY` controls the export directory to use. By default, the default
export path is used.

`proiel:text:import`
--------------------

This task is used to import _new_ base texts. The import will look for the appropriate
source in the database using the identifier in the XML file to be imported. If it does
not exist, an exception will be raised. It is possible to import a subsection of the
XML file by using the `BOOK` variable to filter on book identifiers. Once a book has
been imported, it cannot be imported again, and an attempt to do is likely to lead to
data corruption.

Example:

    $ rake proiel:text:import FILE=wulfila-gothicnt.xml BOOK=1THESS
    Registered books COL,2THESS,1THESS,MARK,JOHN,PHILEM,ROM,1TIM,PHIL,GAL,EPH,LUKE,2TIM,TIT,2COR,MATT,1COR...
    Importing source wulfila-gothicnt...
    Importing book 1THESS for source wulfila-gothicnt...

`proiel:schemata:export`
------------------------

This task exports the schemata for all export formats. If no directory is supplied,
the default export path is used.

    $ rake proiel:schemata:export
    $ ls -l public/exports/
    total 20
    -rw-r--r-- 1 mlj mlj 5958 2008-09-08 12:56 text.xsd

`proiel:inflections:import`
---------------------------

This task imports inflections. The data should be a comma separated
files with the following fields:

  1. Language code
  2. Lemma and optional variant number separated by a hash mark (#)
  3. Part of speech
  4. Inflected form
  5. Positional tag(s) with morphology

e.g.

    got,and-haitan,,andhaihaist,V-2suia-----

`proiel:inflections:export`
---------------------------

This task exports inflections. The format is the same as for
`proiel:inflections:import`.
