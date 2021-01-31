*! version 0.0.0.9000 Jay Kim 29jan2021
/***

_version 0.0.0.9000_


start_proj
==========

Description
-----------

This command creates folders in a pre-specified way.
It also stores meta data for a project so that it can be used by other commands.


Syntax
------

> __start_proj__ _project_name_ [, _options_]

> _project_name_ is the folder name of your project.

Options
-------

- **u**nder : Under which directory you want to create your project?
If not provided, the current working directory is assumed.

- **proj**ect : Project title 

- **aut**hor : Author name 

- **d**epends : Any dependencies other than the base commands 

- **stata**ver : Stata version on which your project will be run (default 13). 

- **g**it : Initialize a git repository


Author
------

Jay (Jongyeon) Kim

Johns Hopkins University

jay.luke.kim@gmail.com

[https://github.com/jaylkim](https://github.com/jaylkim)

[https://jaylkim.rbind.io](https://jaylkim.rbind.io)


License
-------

MIT License

Copyright (c) 2021 Jongyeon Kim

_This help file was created by the_ __markdoc__ _package written by Haghish_

***/



program define start_proj

  syntax anything(name=proj_folder id="Project folder name") ///
    [,                      ///
      Under(str)            /// Parent dir 
      PROJect(str)          /// project title
      AUThor(str)           /// Author name
      Depends(namelist)     /// Dependencies other than the base commands
      STATAver(integer 13)  /// Stata version your script will run on
      Git                   /// Set this project as a git repo
    ]

  // Parent dir
  if "`under'" == "" {
    local parent = c(pwd)
  }
  else {
    local parent = `under'
  }

  // Make a root directory
  cap mkdir "`parent'/`proj_folder'"
  if _rc != 0 {
    disp as err "`parent'/`proj_folder' already exists"
    exit
  }

  cd "`parent'/`proj_folder'"

  // Make directories required
  // .              // Project dir
  // |--data        // Raw/processed data
  // |--src         // R or Stata source files
  // |--|-R
  // |--|-stata
  // |--doc         // Documents illustrating your analysis
  // |--ext         // All external files
  // |--output      // Figures/tables created from the analysis
  // |--|-figures
  // |--|-tables

  mkdir "data"
  mkdir "src"
  qui cd "src"
  mkdir "R"
  mkdir "stata"
  qui cd ..
  mkdir "doc"
  mkdir "ext"
  mkdir "output"
  qui cd "output"
  mkdir "figures"
  mkdir "tables"
  qui cd ..

  disp as res "`proj_folder' created"

  // Initializing a git repo
  shell git init
  file open gitignore using ".gitignore", write
  file write gitignore ".DS_Store" _n
  file write gitignore "*.swp" _n
  file write gitignore "ext/" _n
  file write gitignore "data/"
  file close gitignore

  // Make a dta file to store the project meta data
  preserve
  
  drop _all
  qui set obs 1

  qui gen project = "`project'"
  qui gen author = "`author'"
  qui gen dependency = "`depends'"
  qui gen stata_version = "`stataver'"
  qui gen project_dir = "`parent'/`proj_folder'"

  if "`git'" == "" {
    qui gen git = "false"
  }
  else {
    qui gen git = "true"
  }

  qui save config.dta, replace emptyok 
  restore


end
