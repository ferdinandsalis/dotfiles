# Testing Dotfiles Installation

## Testing Strategies

### 1. Local Testing with Backup

The safest way to test on your current machine:

```bash
# Run test with automatic backup
./scripts/test-setup.sh --local

# Restore original setup after testing
./scripts/test-setup.sh --clean
```

### 2. Docker Testing (Isolated)

Test in a clean container environment:

```bash
# Test in Docker container
./scripts/test-setup.sh --docker
```

### 3. Virtual Machine Testing

Most thorough testing with a full OS:

```bash
# Requires Vagrant installed
./scripts/test-setup.sh --vm
```

### 4. Dry Run Testing

Test without making any changes:

```bash
# Validate syntax only
./scripts/test-setup.sh --dry-run
```

## Manual Testing Checklist

Before using on a new machine, verify:

### Pre-Installation
- [ ] Scripts are executable: `ls -la setup.sh scripts/*.sh`
- [ ] Repository is up to date: `git pull`
- [ ] No uncommitted changes: `git status`

### During Installation
- [ ] Architecture detected correctly (Intel/Apple Silicon)
- [ ] Prompts appear for optional features
- [ ] No error messages during execution
- [ ] Fisher plugins install automatically

### Post-Installation
Run the health check:
```bash
./scripts/health-check.sh
```

Verify critical components:
- [ ] Shell: `echo $SHELL` shows Fish
- [ ] Symlinks: All dotfiles linked correctly
- [ ] Commands: Essential tools available (`git`, `brew`, `fish`)
- [ ] Git: Configuration set with `git config --list`
- [ ] SSH: Keys generated in `~/.ssh/`

## GitHub Actions CI

The repository includes automated testing via GitHub Actions:

- **macOS versions**: Tests on macOS 12, 13, and latest
- **Syntax validation**: ShellCheck for all bash scripts
- **Config validation**: YAML and TOML syntax checking
- **Idempotency**: Runs setup twice to ensure no failures

View test results: [Actions tab](https://github.com/ferdinandsalis/dotfiles/actions)

## Common Issues and Solutions

### Issue: Script fails on fresh macOS
**Solution**: Ensure Xcode Command Line Tools install completes before continuing

### Issue: Fish plugins don't install
**Solution**: Fisher requires internet connection; run `fisher_install` manually if needed

### Issue: Symlinks already exist
**Solution**: The scripts handle existing files; they'll prompt before overwriting

### Issue: Homebrew packages fail
**Solution**: Run `brew bundle --file=~/.Brewfile` separately and check for conflicts

## Testing on a New Machine

Recommended approach for tomorrow's new computer:

1. **Clone and test in dry-run first:**
   ```bash
   git clone https://github.com/ferdinandsalis/dotfiles.git ~/.dotfiles
   cd ~/.dotfiles
   ./scripts/test-setup.sh --dry-run
   ```

2. **Run the actual setup:**
   ```bash
   ./setup.sh
   ```

3. **Verify with health check:**
   ```bash
   ./scripts/health-check.sh
   ```

4. **Configure personal settings:**
   ```bash
   ./scripts/setup-git.sh
   ./scripts/setup-ssh.sh
   ```

## Rollback Strategy

If something goes wrong:

1. **Restore from Time Machine** (if available)
2. **Manual cleanup:**
   ```bash
   # Remove symlinks
   rm ~/.gitconfig ~/.Brewfile
   rm -rf ~/.config/fish ~/.config/atuin
   
   # Remove dotfiles
   rm -rf ~/.dotfiles
   
   # Reset shell to bash
   chsh -s /bin/bash
   ```

## Contributing Tests

When adding new features:

1. Update `scripts/health-check.sh` to verify the feature
2. Add test cases to `scripts/test-setup.sh`
3. Ensure idempotency - feature can be installed multiple times
4. Document any manual testing required