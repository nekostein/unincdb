#set text(
  font: "Times New Roman",
  size: 10pt,
)

#set page(paper: "a4", margin: (left: 210mm - 25mm - 36em, right: 25mm, top: 90mm, bottom: 37mm))
#let tomldata = toml("UNINC.toml")

= Example Typst Document
#v(2em)


This is another example altdoc using Typst.
#v(2em)

#let make_entry(body1) = {
  text(weight: "bold")[#body1]
}
#let showdata(entry_name, entry_key, is_big) = {
  let tomldata2 = toml("UNINC.toml")
  make_entry(entry_name)
  if (is_big) {
    linebreak()
    text(size: 12pt)[#tomldata2.at(entry_key)]
  } else {
    h(1em)
    tomldata2.at(entry_key)
  }
  parbreak()
}


#showdata([Business Name], "fullname", true)
#v(1em)
#showdata([Type], "type", false)
#showdata([Date of Creation], "date_creation", false)
#showdata([Status], "status", false)
#showdata([President], "president", false)
#showdata([Secretary], "secretary", false)
#showdata([Charter Hash], "charter_hash", false)
#showdata([Fields of Conduct], "fields", false)


#v(1fr)



#let dburl = "https://unincdb.nekostein.com/" + sys.inputs.ORGDIR.split("/").slice(1).join("/") + ".pdf"
Online query:\
#link(dburl)[#dburl]






