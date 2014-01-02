# Gmail to PDF

Exports emails from your Gmail account to PDF

## Requirements

* [Gmail gem](https://github.com/nu7hatch/gmail)
* [Prawn gem](https://github.com/prawnpdf/prawn)
* [Highline gem](https://github.com/JEG2/highline)

## Usage

Rename config.example.yml to config.yml, specify criteria and run:

    ruby export.rb

It will ask you for your Gmail address and password and generate PDF file with the emails matching the criteria.

If save_attachments setting set to true it will save all attachments on your hard drive (attachments directory).

## License

Licensed under the [MIT License](http://creativecommons.org/licenses/MIT/)