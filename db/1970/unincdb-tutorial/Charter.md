This is a tutorial article for the usage of the UNINCDB project.

Last revision: 2024-05-20



# Introduction

Maintaining a dormant company in the UK costs around $80 a year.
A Delaware company can cost like around $225.
There are occasions that a few people want to setup some rules on
how their small organization should operate,
but the cheapest legal instruments are not really affordable until things start generating revenues.

If you intend to become a notary authority, you will later find a section for this topic.


# Workflow Overview
- Write a Charter and an Appendix.
- Write the formatted "UNINC.toml" file.
- Submit the 3 files ("Charter.md", "Appendix.md", "UNINC.toml") to this repository via a pull request.
- Request a notary authority to issue a letter of notary witness.
- Find your letter published in a database hosted by the notary authority.







# Write a Charter

Write a simple charter that outlines how the organization should operate.
Declare decision-making procedures and leadership duties.

Consult company formation blogs if you have questions.
Many are written by lawyers and agencies and they are worth your reading since you will eventually start an incorporated business.

Use basic Markdown syntax. Avoid inline code; prefer quotation marks when possible.
Keep in mind that printed stuff will not necessarily be colorful
and there is no guarantee that a notary authority will use different fonts for "&lt;code>" and "&lt;pre>".





# Metadata and Contacts

## The Manifest TOML File

### Overview

First have a look at the "UNINC.toml" file of this tutorial data entity.
It should contain most metadata fields that would otherwise appear on a Certificate of Incorporation.

While values of the data fields are not necessarily in English,
any notary authority may decline filings using languages beyond their ability.

```
fullname = "SAMPLE DATA FOR UNINCDB TUTORIAL"
type = "Committee"
date_creation = "1970-01-01"
status = "Active"
fields = "Information Technology; Notary Service"
president = "NERUTHES"
secretary = "NERUTHES"
charter_hash = "[......................................]"
addresses = [
    "https://github.com/nekostein/unincdb",
]
notary = [
    "https://unincdb.nekostein.com/1970/unincdb-tutorial.pdf"
]
```

### "fullname"
Declare the full name of your business. Incorporated companies often use "Inc", "Co.,Ltd", or "LLC".
Similarly, choose from the following suffix options: "Uninc" and "Club".

Consider some name like "Rusty Lake Swim Safety Station Uninc" or "Rusty Lake Fishing Club".

Write in all uppercase.

### "type"
Declare the type of the organization.

Your options:

- Committee
- Quasi-LLC
- Quasi-CCorp
- Quasi-SCorp
- Quasi-Partnership

If you choose any "Quasi-" type, you mean that this unincorporated organization is
a prelude for forming a company or partnership as indicated.

### "date_creation"
The date when the unincorporated organization is founded. Can be different from filing date.
Best reflect the anniversary date.

Format: YYYY-MM-DD.

### "status"
You have 4 options.

| Option    | Description                                                                 |
| --------- | --------------------------------------------------------------------------- |
| Active    | Business operational.                                                       |
| Dormant   | Not actively working.                                                       |
| Dissolved | No longer exists.                                                           |
| Replaced  | An incorporated organization has replaced this unincorporated organization. |

Remember to come back to update this value when the status is changed.

### "fields"
Fields of conduct. Separate with semicolons.

Example:

```
Software Development; Software Licensing; Advertising
```

### "president"
The person who has the primary leadership.

Write in all uppercase.

### "secretary"
The person who manages files.
Can be the same person as the President.

Write in all uppercase.

### "charter_hash"
The SHA-1 hash of "Charter.md" file.

The algorithm is no longer secure, but we cannot bear longer hashes.

### "addresses"
A list of addresses. Should be URLs in most situations. A street address may or may not be accepted.

### "notary"
A list of URLs where letters of notary witness can be found.
This field makes cross reference easier.





# Complete the Appendix

There is no specific requirements on what the Appendix should include.
But for everyone's convenience,
digital signatures (GnuPG or OpenSSH or X.509, whatever toolkit you prefer)
of the Charter by the President and the Secretary will be great.

For example, use the following command.

```
gpg --pinentry-mode loopback --output - \
  --sign -ab db/1970/unincdb-tutorial/Charter.md
```





# Notary Authorities

## Data Autonomy
This git repository is designed to afford great portability,
especially for notary authorities which prefer not to push data back to the upstream.
A notary authority can keep its tools private even if it exchanges data with the upstream.

The following subsections explain how you can set up your own notary authority.

Note: For each environmental variable found in ".env", make sure to configure its value in ".myenv".

## Private Tools
A notary authority (e.g. "Pear Inc") shall prepare the following tools
in its private directory "authorities/PearInc".

### "toml2tex.sh"
This is a shell script. It is responsible for generating LaTeX code pieces from the manifest TOML file for later use.

The following lines are what you should do at the beginning of the script.

```
tomlpath="$1"
workdir="$(dirname "$tomlpath")"
outfn="$1.$OFFICE.1.texpart"
echo '' > "$outfn"
```

### "witness.tex"
This is the main LaTeX template.

## PDF Generation

Pass the relative path of the TOML file to "make.sh".

```
./make.sh db/1970/unincdb-tutorial/UNINC.toml
```

The "make.sh" script is straightforward and is easy to understand.

In short, the building workflow consists of several stages:

- Use Pandoc to generate ".texpart" components for "Charter.md" and "Appendix.md".
- Run the "toml2tex.sh" script to generate ".texpart" components to be used in the LaTeX template.
- Symlink from "authorities/PearInc/witness.tex" to "db/1970/unincdb-tutorial/witness-PearInc.tex".
- Use XeLaTeX to build the symlink file. Note: If you want to use a different LaTeX building command, override using "$LATEXBUILDCMD".
- Move the PDF artifact to "_dist/www/PearInc/1970/unincdb-tutorial.pdf".

Now you can publish the directory "_dist/www/PearInc" as a website so people can see notary letters you made.

