
## sh script to create routing lists
#### for keenetic routers

#### NOTE: only for linux env

1. Create new file `domain` and put there domain names like:
``` 
domain1.site
domain2.site
domain3.site
domain4.site
domain5.site
```
2. Run script `makeroutes.sh`
```sh
./makeroutes.sh
```
 - if it not run make this:
```sh 
 chmod +x ./makeroutes.sh
```
3. This script will generate two files `routes.bat` `routes.cli`.
4. Clear routes in you keenetic router.
5. You can import routes from `routes.bat` to your router with web-interface.
6. Also, you can import routes using `expect.sh`. You must turn on SSH-server on you keenetic router.
7. Create file `password.txt` with your password for keenetic router.
8. Run `expect.sh`:
```
./expect.sh
```

Note: `makeroutes_srv.sh`, `copy_to_srv.sh`, `clearfolder.sh` my helper scripts.