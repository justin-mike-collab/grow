# SPA Standards

## Technology Stack
 - VueJs v3 
 - Vite v7.2
 - TypeScript v5.9
 - Vuetify v3.11
 - Vue Router v4
 - Pinia v3
 - TanStack Query (Vue Query) v5
 - Cypress E2E v15.8

## Standard Developer Commands
- npm run build (package code for deployment)
- npm run dev (run dev server)
- npm run test (run unit tests)
- npm run test:coverage (run unit tests with coverage report)
- npm run test:ui (run unit tests with Vitest UI)
- npm run cypress (open Cypress E2E test runner)
- npm run cypress:run (run Cypress E2E tests headlessly)
- npm run api (start db + api containers)
- npm run service (start db + api + spa containers)
- npm run container (build SPA container)

## Configurability
- /api/config will return runtime configuration values
- Use runtime configuration values for enumerator values not OpenAPI Spec
- Container uses NGINX template substitution for API proxy configuration

## Dependency Management
- Always verify peer dependency compatibility when adding or updating packages
- Use `npm view <package> peerDependencies` to check version requirements
- Key compatibility requirements:
  - `@vitejs/plugin-vue` v6.x required for Vite v7.x (v5.x only supports Vite v5-v6)
  - `@mdi/font` latest stable is v7.x (v8.x does not exist)
- Run `npm install` after dependency changes to catch peer dependency conflicts early

## Testing Standards
- **Unit Testing**: Vitest v3 for unit testing with 90% coverage target
- **E2E Testing**: Cypress v15.8 for end-to-end testing
- **Coverage Requirements**:
  - API client: 90% lines, 90% functions, 75% branches
  - Composables: 90% lines, 90% functions, 60% branches
  - Components: 90% lines, 90% functions, 85% branches
  - Pages tested via E2E tests
- **Test Organization**:
  - Unit tests: `src/**/*.test.ts` (co-located with source)
  - E2E tests: `cypress/e2e/**/*.cy.ts`
  - Test support: `cypress/support/`
- **Testing Patterns**:
  - Mock external dependencies (API calls, localStorage)
  - Use shallow mounting for component tests to avoid Vuetify CSS issues
  - E2E tests cover all main user workflows
  - Custom Cypress commands for common operations (e.g., login)

## Authentication Pattern
- JWT tokens stored in localStorage (`access_token`, `token_expires_at`)
- `useAuth()` composable manages authentication state
- `/dev-login` endpoint for development (not proxied, direct to API)
- Router guards protect authenticated routes
- Config loaded after successful login

## Component Patterns
- **AutoSave Components**: Field-level save-on-blur for edit pages
  - `AutoSaveField`: Text input with auto-save (supports textarea mode)
  - `AutoSaveSelect`: Select dropdown with auto-save
  - Show saving/saved/error states
  - Accept `onSave` callback returning Promise

## Data Management
- **TanStack Query** (Vue Query) for server state
- Query keys: `['resource', id]` or `['resources', filters]`
- Mutations invalidate related queries on success
- No state duplication between server and client

## Automation IDs

### Philosophy

Automation IDs (`data-automation-id` attributes) are **sacred geometry** - stable API contracts that enable programmatic interaction with the UI. Once established, these IDs should:

- **Survive refactoring**: Changes to component structure, styling, or text content should NOT change automation IDs
- **Be carefully chosen**: Select meaningful, descriptive IDs that reflect the element's purpose, not its implementation
- **Remain stable**: Only change automation IDs when there are breaking changes to the element's purpose or function
- **Be documented**: Treat ID changes like API versioning - document breaking changes

### Purpose

Automation IDs support multiple use cases:
- **Testing frameworks**: Cypress, Playwright, Selenium, etc.
- **Browser automation**: Puppeteer, Chromium DevTools Protocol
- **RPA tools**: UiPath, Automation Anywhere, Blue Prism
- **Workflow automation**: Zapier, Make, n8n
- **AI agents**: Browser-based AI assistants and autonomous agents
- **Accessibility tools**: Screen readers and assistive technologies

### Naming Convention

Follow the pattern: `{domain}-{page}-{element}`

**Components**:
- `{domain}`: The business domain (control, create, consume, etc.)
- `{page}`: The page type (list, new, edit, view, admin)
- `{element}`: The element's purpose (search, name-input, submit-button, etc.)

**Examples**:
```html
<!-- List page -->
<input data-automation-id="control-list-search" />
<button data-automation-id="control-list-new-button" />

<!-- New/Create page -->
<input data-automation-id="control-new-name-input" />
<textarea data-automation-id="control-new-description-input" />
<select data-automation-id="control-new-status-select" />
<button data-automation-id="control-new-submit-button" />
<button data-automation-id="control-new-cancel-button" />

<!-- Edit page -->
<input data-automation-id="control-edit-name-input" />
<button data-automation-id="control-edit-save-button" />

<!-- Navigation -->
<button data-automation-id="nav-drawer-toggle" />
<a data-automation-id="nav-controls-list-link" />
```

### Implementation Guidelines

1. **Add to all interactive elements**:
   - Form inputs (text, textarea, select, checkbox, radio)
   - Buttons (submit, cancel, action buttons)
   - Links that trigger navigation or actions
   - Data tables and their controls

2. **Add to key display elements**:
   - Page headings (for verification)
   - Data display fields on view pages
   - Error/success messages
   - Loading states

3. **Use descriptive suffixes**:
   - `-input` for text/textarea inputs
   - `-select` for dropdown/select elements
   - `-button` for clickable buttons
   - `-link` for navigation links
   - `-checkbox` / `-radio` for boolean inputs
   - `-display` for read-only data display
   - `-table` for data tables

4. **Keep IDs semantic, not structural**:
   - ✅ Good: `control-new-name-input` (describes purpose)
   - ❌ Bad: `form-field-1` (describes structure)
   - ✅ Good: `control-list-search` (describes what it does)
   - ❌ Bad: `input-at-top-left` (describes location)

5. **One ID per interactive element**:
   - Don't reuse automation IDs across different elements
   - If an element has multiple purposes, choose the primary purpose for the ID

### Testing with Automation IDs

In Cypress tests:
```javascript
// Instead of fragile selectors like:
cy.contains('label', 'Name').parent().parent().find('input').type('value')

// Use automation IDs:
cy.get('[data-automation-id="control-new-name-input"]').type('value')
```

### Breaking Changes

Treat automation ID changes as **breaking changes to the UI API**:

1. **Document the change**: Note in commit messages and release notes
2. **Update all tests**: Ensure E2E tests reflect the new IDs
3. **Consider migration**: If external automation depends on the old ID, provide a migration window
4. **Only when necessary**: Change IDs only when the element's purpose fundamentally changes

### Version Control

- Automation IDs are part of your codebase and should be reviewed in PRs
- Reviewers should flag unexpected changes to existing automation IDs
- New features should include automation IDs from the start, not added later

## spa_utils Package

The `@{{org.git_org}}/spa_utils` npm package provides reusable Vue 3 + Vuetify components, composables, and utilities for all SPAs.

### Installation

**Development (Editable Mode):**
```json
{
  "dependencies": {
    "@{{org.git_org}}/spa_utils": "file:../spa_utils"
  }
}
```

**Production (GitHub npm):**
```json
{
  "dependencies": {
    "@{{org.git_org}}/spa_utils": "github:{{org.git_org}}/spa_utils#v0.1.0"
  }
}
```

**Configure .npmrc:**
```
@{{org.git_org}}:registry=https://npm.pkg.github.com
//npm.pkg.github.com/:_authToken=${GITHUB_TOKEN}
```

### Available Exports

**Composables:**
- `useErrorHandler(error)` - Handle errors from queries/mutations
- `useResourceList<T>(options)` - Generic list page pattern with search support
- `useRoles(authProvider?, configProvider?)` - Role-based access control with dependency injection

**Components:**
- `AutoSaveField` - Text input/textarea with auto-save on blur
- `AutoSaveSelect` - Select dropdown with auto-save on blur
- `ListPageSearch` - Reusable search field for list pages

**Utilities:**
- `formatDate(dateString)` - Format ISO date strings to localized strings
- `validationRules` - Common validation rules (required, namePattern, descriptionPattern)

### Usage Patterns
See spa_utils for examples of how to implement these patterns.
**List Pages with Search:**
**Auto-Save Components:**
**Role-Based Access Control:**

### Best Practices

1. **Always enable search for list pages** - Use `searchable: true` and provide `searchQueryFn` for all list pages
2. **Use dependency injection for useRoles** - Create app-specific wrapper that provides auth/config providers
3. **Import from main package** - Use `import { ... } from '@{{org.git_org}}/spa_utils'` for all utilities
4. **Follow automation ID patterns** - Use `{domain}-{page}-{element}` pattern for all interactive elements
5. **Reuse validation rules** - Use `validationRules` from spa_utils instead of creating custom rules
6. **Consistent date formatting** - Always use `formatDate` from spa_utils for date display

### Search Functionality

All list pages should support search by name. The `useResourceList` composable provides:
- Automatic debouncing (300ms)
- Query key management with search query
- Configurable search function

**Required API Support:**
```typescript
// API client should support optional nameQuery parameter
async getResources(nameQuery?: string): Promise<Resource[]> {
  const query = nameQuery ? `?name=${encodeURIComponent(nameQuery)}` : ''
  return request<Resource[]>(`/resource${query}`)
}
```

## Security
- Run `npm audit` regularly to identify security vulnerabilities
- Use `npm audit --audit-level=high` to focus on high/critical issues
- For vulnerabilities in transitive dependencies, use `overrides` in package.json to force secure versions
- Example: `"overrides": { "qs": "^6.14.1" }` to fix vulnerabilities in Cypress dependencies
- Verify fixes with `npm audit` and `npm ls <package>` to confirm version resolution
