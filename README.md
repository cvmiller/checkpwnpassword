# A Pwded Password Checker

With Data Breaches seemingly happening all the time, over the years, over **308 million passwords** have been exposed. Over **7 Billion data records** have been breached in 2021 alone [see securitymagazine article](https://www.securitymagazine.com/articles/96667-the-top-data-breaches-of-2021).

## What checkpwnpassword.sh does

`checkpwnpassword.sh` uses the [haveibeenpwned API 3](https://haveibeenpwned.com/API/v3#SearchingPwnedPasswordsByRange) to securely check if your password is in their 308 Million database. **Your password never leaves your machine**. It does this by:

1. Enter your password into `checkpwnpassword.sh` 
2. The script will create a **SHA1** hash of your password
3. The first 5 characters of the 40 byte-long hash are sent to the [haveibeenpwned API 3](https://haveibeenpwned.com/API/v3#SearchingPwnedPasswordsByRange), which returns a list of SHA1 hashes which start with your 5 character hash.
4. The script then searches to see if *your hash* matches any of the hashes in the return list
5. If so, it will report that a match has been found, and display the matching haveibeenpwned hash

## Why should I use it?

It is good for testing if your local device passwords are floating out on the internet. By ensuring that your *clear* password never leaves your machine (it is not written to any temporary files, either), you can feel confident entering your password, and not having it *collected* on some password checking website.

## Downloading checkpwnpassword.sh

Download `checkpwnpassword.sh` to any directory (such as your home directory) and make it executable by:

`chmod 700 checkpwnpassword.sh`

Examine the **help** by executing the script with a *dot slash* in front of the script, which tells the shell to look in *this* directory for the program.

```
$ ./checkpwnpassword.sh -h
	./checkpwnpassword.sh - check haveibeenpwned password database 
	    for more info see:
	    https://haveibeenpwned.com/API/v3#SearchingPwnedPasswordsByRange
	
	e.g. ./checkpwnpassword.sh -p  <password> 
	-d  debug
	
 By Craig Miller - Version: 0.95
```

### Running the script

Your password can be entered in one of two ways, via the `-p mypassword` parameter, or interactively, typing the password in directly. The downside of using the `-p` option is that your password will be recorded in the shell history file, generally not desired, but it can be easier for scripting.

The second method is prefered, as your password will be assigned a variable in the script while the the script is running, and then will disappear at script termination. In operation it looks like this where I entered *123456* as the password:

```
$ ./checkpwnpassword.sh 
Enter password: 
Password matches HAVEIBEENPWNED_API
SHA1 Match: 7C4A8D09CA3762AF61E59520943DC26494F8941B, 37359195 times
pau
```

The [haveibeenpwned API 3](https://haveibeenpwned.com/API/v3#SearchingPwnedPasswordsByRange) also reports how many records of the 308 Million database match your password (hint: don't use 123456 as your password).

If you have a secure password that isn't in the database, the output is:

```
$ ./checkpwnpassword.sh 
Enter password: 
Password appears safe, unknown to HAVEIBEENPWNED_API
pau
```



## Why is it written in Bash?

For two reasons:

1. Bash runs everywhere, from Raspberry Pi, to Windows Subsystem for Linux (WSL).
2. It is easy to read, and therefore the source is easy to validate.

## Requirements

The script requires the following, which is probably already installed on your Linux system:

1. `sha1sum1` it checks for this before running
2. `curl` the script also checks for this

## What the script doesn't do

It *doesn't* validate your **email** and **password** combination from haveibeenpwned. There is another script [checkpwn](https://github.com/brycx/checkpwn) which will do this.





