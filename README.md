<div align="center" markdown="1">

<img src="docs/images/logo.png" width="80" />


# ERPNext TNT Integration

**ERPNext TNT Integration**
![demo screenshot](docs/images/screenshot.png)
</div>


### ERPNext TNT Integration

![CI workflow](https://github.com/Starktail/erpnext_tnt/actions/workflows/ci.yml/badge.svg?branch=version-15)

[![codecov](https://codecov.io/github/Starktail/erpnext_tnt/graph/badge.svg?token=12QO3B73LJ)](https://codecov.io/github/Starktail/erpnext_tnt)

ERPNext TNT Integration


### License

Starktail (Pty) Ltd


### User documentation

📄 [ERPNext TNT Integration Documentation](https://erpnext-tnt-docs.starktail.com/erpnext_tnt_introduction)

### Installation

You can install this app using the [bench](https://github.com/frappe/bench) CLI:

```bash
cd $PATH_TO_YOUR_BENCH
bench get-app $URL_OF_THIS_REPO --branch develop
bench install-app erpnext_tnt
```

### Development

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

#### Contributing

This app uses `pre-commit` for code formatting and linting. Please [install pre-commit](https://pre-commit.com/#installation) and enable it for this repository:

```bash
cd apps/erpnext_tnt
pre-commit install

#(optional) Run against all the files
pre-commit run --all-files
```

Pre-commit is configured to use the following tools for checking and formatting your code:

- ruff
- eslint
- prettier
- pyupgrade


We use [Semgrep](https://semgrep.dev/docs/getting-started/) rules specific to [Frappe Framework](https://github.com/frappe/frappe)
```shell
# Install semgrep
python3 -m pip install semgrep

# Clone the rules repository
git clone --depth 1 https://github.com/frappe/semgrep-rules.git frappe-semgrep-rules

# Run semgrep specifying rules folder as config 
semgrep --config=/workspace/development/frappe-semgrep-rules/rules apps/erpnext_tnt
```

#### Updating Documentation

For documentation, we use [vitepress](https://vitepress.dev/). You can run `yarn docs:dev` to preview the docs when applying changes

#### CI

This app can use GitHub Actions for CI. The following workflows are configured:

- CI: Installs this app and runs unit tests on every push to `develop` branch.
- Linters: Runs [Frappe Semgrep Rules](https://github.com/frappe/semgrep-rules) and [pip-audit](https://pypi.org/project/pip-audit/) on every pull request, as well as [Semgrep](https://semgrep.dev/docs/getting-started/)

