(lang dune 3.15)

(name typingthing)

(generate_opam_files true)

(source
 (github username/reponame))

(authors "kimierik")

(maintainers "Maintainer Name")

(license LICENSE)

(documentation https://url/to/documentation)

(package
 (name typingthing)
 (synopsis "A short synopsis")
 (description "A longer description")
 (depends ocaml dune unix)
 (tags
  (topics "to describe" your project)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
