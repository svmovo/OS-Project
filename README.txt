File Auditor & Backup Tool
Operating Systems - Alexandria National University

Team:
- Sameh Mahmoud (ID: 2306012) : wrote and tested the project functions
- Masoud Mahmoud (ID: 2306085) : wrote and tested the project functions

Files:
- auditor.sh : settings, the 7 features, the menu and command-line mode
- lib.sh     : helper functions (log_info, log_error, log_action, require_dir)

How to run:
1) chmod +x auditor.sh lib.sh
2) Menu mode:          ./auditor.sh ../sample_data
3) Command-line mode:  ./auditor.sh ../sample_data scan
   Actions: scan | perms | ext | backup

Notes:
- Run the script from inside its own folder.
- Backups are saved in the "backups" folder inside the chosen directory.
- Every action is logged in auditor.log.
