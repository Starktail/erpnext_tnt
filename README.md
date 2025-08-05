## ERPNext TNT Integration

![CI workflow](https://github.com/dvdl16/erpnext_tnt/actions/workflows/ci.yml/badge.svg?branch=version-15)

[![codecov](https://codecov.io/gh/dvdl16/erpnext_tnt/graph/badge.svg?token=12QO3B73LJ)](https://codecov.io/gh/dvdl16/erpnext_tnt)

A TNT Express integration for ERPNext

#### License

MIT

#### Manual Installation

1. [Install bench](https://github.com/frappe/bench).
2. [Install ERPNext](https://github.com/frappe/erpnext#installation).
3. Once ERPNext is installed, add the erpnext_tnt app to your bench by running

	```sh
	$ bench get-app https://github.com/dvdl16/erpnext_tnt
	```
4. After that, you can install the erpnext_tnt app on the required site by running
	```sh
	$ bench --site sitename install-app erpnext_tnt
	```


#### Tests

To run unit tests:

```shell
bench --site test_site run-tests --app erpnext_tnt --coverage
```

To run UI/integration tests:

The following depencies are required
```shell
sudo apt update
# Dependencies for cypress: https://docs.cypress.io/guides/continuous-integration/introduction#UbuntuDebian
sudo apt-get install libgtk2.0-0 libgtk-3-0 libgbm-dev libnotify-dev libgconf-2-4 libnss3 libxss1 libasound2 libxtst6 xauth xvfb

sudo apt-get install chromium
```

```shell
bench --site test_site run-ui-tests erpnext_tnt --headless --browser chromium
```

If you get the following error:
```shell
No version of Cypress is installed in: /home/frappe/.cache/Cypress/10.x.x/Cypress

Please reinstall Cypress by running: cypress install
```

just run:
```shell
./node_modules/.bin/cypress install
```

#### Development

We use [pre-commit](https://pre-commit.com/) for linting. First time setup may be required:
```shell
# Install pre-commit
pip install pre-commit

# Install the git hook scripts
pre-commit install

#(optional) Run against all the files
pre-commit run --all-files
```

We use [Semgrep](https://semgrep.dev/docs/getting-started/) rules specific to [Frappe Framework](https://github.com/frappe/frappe)
```shell
# Install semgrep
python3 -m pip install semgrep

# Clone the rules repository
git clone --depth 1 https://github.com/frappe/semgrep-rules.git frappe-semgrep-rules

# Run semgrep specifying rules folder as config 
semgrep --config=/workspace/development/frappe-semgrep-rules/rules apps/erpnext_tnt
```

If you use VS Code, you can specify the `.flake8` config file in your `settings.json` file:
```shell
"python.linting.flake8Args": ["--config=frappe-bench-v15/apps/erpnext_tnt/.flake8_strict"]
```


#### Print Formats

See `docs > print_format_generation > main.py` for steps to generate HTML print formats from TNT `XML` and `XSL` fies
