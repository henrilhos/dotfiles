# Generate a pull request using GitHub CLI

This guide explains how to create pull requests using GitHub CLI in our project.

## Prerequisites

1. Install GitHub CLI if you haven't already:

   ```bash
   # macOS
   brew install gh

   # Windows
   winget install --id GitHub.cli

   # Linux
   # Follow instructions at https://github.com/cli/cli/blob/trunk/docs/install_linux.md
   ```

2. Authenticate with GitHub:
   ```bash
   gh auth login
   ```

## Creating a New Pull Request

1. First, prepare your PR description following the template in @.github/pull_request_template.md

2. Use the `gh pr create` command to create a new pull request:

   ```bash
   # Basic command structure
   gh pr create --title "feat(scope): Your descriptive title" --body "Your PR description" --base main --assignee @me --reviewer AbraoDaniel,tchiteu --draft
   ```

   For more complex PR descriptions with proper formatting, use the `--body-file` option with the exact PR template structure:

   ```bash
   # Create PR with proper template structure
   gh pr create --title "feat(scope): Your descriptive title" --body-file <(echo -e "## Issue\n\n- resolve:\n\n## Why is this change needed?\nYour description here.\n\n## What would you like reviewers to focus on?\n- Point 1\n- Point 2\n\n## Testing Verification\nHow you tested these changes.\n\n## What was done\npr_agent:summary\n\n## Detailed Changes\npr_agent:walkthrough\n\n## Additional Notes\nAny additional notes.") --base main --assignee @me --reviewer AbraoDaniel,tchiteu --draft
   ```

## Best Practices

1. **PR Title Format**: Use conventional commit format

   - Examples:
     - `feat(supabase): Add staging remote configuration`
     - `fix(auth): Fix login redirect issue`
     - `docs(readme): Update installation instructions`

2. **Description Template**: Always use our PR template structure from @.github/pull_request_template.md:

   - 📋 Escopo
     - Descreva brevemente o que está sendo alterado neste PR
   - ⚠️ Problemas Conhecidos
     - Liste problemas conhecidos que ainda precisam ser resolvidos ou limitações da implementação atual
   - 📸 Evidências
     - Forneça evidências de que as alterações funcionam conforme esperado
   - 🧪 Roteiro de Testes (Caminho Feliz)
     - Descreva o passo a passo para testar as funcionalidades implementadas
   - ✅ Critérios de Aceitação
     - Liste os critérios que devem ser atendidos para que o PR seja aprovado
   - 🎯 Pontos de Impacto
     - Identifique áreas/sistemas que podem ser impactados por estas mudanças

3. **Template Accuracy**: Ensure your PR description precisely follows the template structure:

   - Keep all section headers exactly as they appear in the template
   - Don't add custom sections that aren't in the template
   - Write the PR description in Brazilian Portuguese

4. **Draft PRs**: Start as draft when the work is in progress
   - Use `--draft` flag in the command
   - Convert to ready for review when complete using `gh pr ready`

### Common Mistakes to Avoid

1. **Incorrect Section Headers**: Always use the exact section headers from the template
2. **Modifying PR-Agent Sections**: Don't remove or modify the `pr_agent:summary` and `pr_agent:walkthrough` placeholders
3. **Adding Custom Sections**: Stick to the sections defined in the template
4. **Using Outdated Templates**: Always refer to the current @.github/pull_request_template.md file

### Missing Sections

Always include all template sections, even if some are marked as "N/A" or "None"

## Related Documentation

- [Conventional Commits](https://www.conventionalcommits.org/)
- [GitHub CLI documentation](https://cli.github.com/manual/)
