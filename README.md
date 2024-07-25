# jeos-firstboot
## Description
jeos-firstboot allows initial configuration and adjustments of a Linux system using text based dialogs.

It is a lightweight and customisable firstboot wizard that allows to set basic system settings during and after the first boot of an image. Including showing the license and prompt for language, keyboard, timezone, root passsword and network configuration..

This is mainly developed for openSUSE and SUSE Linux Enterprise Server JeOS images. For more information visit the [JeOS wiki](https://en.opensuse.org/Portal:JeOS).

## Installation

The RPM package is developed in openSUSE OBS [devel package](https://build.opensuse.org/package/show/devel:openSUSE:Factory/jeos-firstboot)

You can also get binaries RPM for openSUSE flavours at [package download](https://software.opensuse.org/package/jeos-firstboot)
<!-- USAGE EXAMPLES -->
## Usage

jeos-firstboot is used as two systemd services [jeos-firstboot.service](https://github.com/openSUSE/jeos-firstboot/blob/master/files/usr/lib/systemd/system/jeos-firstboot.service) and [jeos-firstboot-snapshot](https://github.com/openSUSE/jeos-firstboot/blob/master/files/usr/lib/systemd/system/jeos-firstboot-snapshot.service), for using it you need to copy the appropriate service files and enable it.

You can check the example in the RPM package for installation.

The service is controlled by a file, so after installing it you should be sure that your system is configured appropriately

```sh
# Enable jeos-firstboot
mkdir -p /var/lib/YaST2
touch /var/lib/YaST2/reconfig_system

systemctl mask systemd-firstboot.service
systemctl enable jeos-firstboot.service
```
Beside the service that runs on firstboot there is also a tool to change configuration in a running system, this will also be installed and available as `jeos-config`

jeos-config usage:
```
Usage: jeos-config [OPTION...] [CONFIG_NAME]
Configure system settings using an interactive dialog

	-h              shows this usage help
	locale          Show configuration for locale
	keytable        Show configuration for keyboard
	timezone        Show configuration for timezone
	password        Show configuration for password
	network         Show configuration for network
	raspberrywifi   Show configuration for raspberrywifi
```     
Additional modules (like raspberrywifi) are shown if present.

If no parameter is given it shows a dialog for selection.

## Writing modules

jeos-firstboot can be extended using modules written in bash placed in `/usr/share/jeos-firstboot/modules/` or `/etc/jeos-firstboot/modules/`. Modules in `/etc/jeos-firstboot/modules/` will be preferred. If a link to `/dev/null` is encountered, the module is skipped.

The basename of the module file is its name. It is used as prefix of properties and hooks. It is also used as argument to jeos-config when calling the module directly.

### Properties

```sh
# Shown in jeos-config for module selection
yourmodule_title="Title of your module"
# Shown in jeos-config --help
yourmodule_description="Show an awesome dialog with a nice button"
# Priority of the module. Modules with higher priority are run later in jeos-firstboot and shown below in jeos-config.
# The default is 50.
yourmodule_priority=50
```

### Hooks

```sh
# Runs if called by jeos-firstboot, currently after systemd-firstboot is called
# (that should probably be changed)
yourmodule_systemd_firstboot() { }
# Runs if called by jeos-firstboot, after all systemd_firstboot hooks.
yourmodule_post() { }
# Runs if called by jeos-config
yourmodule_jeos_config() { }
# Runs at the end of jeos-firstboot just before exiting.
yourmodule_cleanup() { }
```

<!-- CONTRIBUTING -->
## Contributing

Any contributions you make are greatly appreciated.

Feel free to create any [Issues](https://github.com/openSUSE/jeos-firstboot/issues) and send pull requests to this repository.

<!-- LICENSE -->
## License

Distributed under the MIT License. See [LICENSE](https://github.com/openSUSE/jeos-firstboot/blob/master/LICENSE) for more information.

## Credentials

jeos-firstboot supports [systemd credentials](https://systemd.io/CREDENTIALS/)
to pre-configure systems. The wizard does not prompt for settings
defined by credentials.

* firstboot.keymap
* firstboot.license-agreed
* firstboot.locale
* firstboot.timezone
* passwd.plaintext-password.root
