# `/tdd` — Test-Driven Development (TDD)

## What it is

A skill that implements the red-green-refactor TDD cycle in a disciplined way. Builds features or fixes bugs by writing a failing test first, then implementing the minimum needed to make it pass, and repeating.

## What it's for

- When you want to build a new feature with tests from the start
- When you want to fix a bug and make sure it doesn't come back
- When you want integration tests for a specific module
- When you've already tried writing code without tests and are having trouble testing afterwards

## How to invoke

```
/tdd
```

Describe what you want to build or fix.

## How it works

### Core philosophy

**Tests should verify behaviour through public interfaces, not implementation details.** The code can change completely; the tests shouldn't need to change.

Good test: exercises real code through public APIs, describes *what* the system does. Survives refactorings because it doesn't care about internal structure.

Bad test: mocks internal collaborators, tests private methods, or verifies through external means. Warning sign: the test breaks when you refactor, but the behaviour didn't change.

### Anti-pattern: horizontal slices

**Do NOT** write all tests first, then all implementation. This produces bad tests written for imagined — not real — behaviour.

```
WRONG (horizontal by layer):
  RED:   test1, test2, test3, test4, test5
  GREEN: impl1, impl2, impl3, impl4, impl5

RIGHT (vertical):
  RED→GREEN: test1→impl1
  RED→GREEN: test2→impl2
  ...
```

### Process

**1. Planning** — before writing any code:
- Confirms with the user which interface changes are needed
- Confirms which behaviours to test (prioritises)
- Identifies deep module opportunities (small interface, rich implementation)
- Lists the behaviours to test (not implementation steps)
- Asks for plan approval

**2. Tracer bullet** — writes ONE test that confirms ONE thing:
```
RED:   Write test for the first behaviour → test fails
GREEN: Write minimum code to pass → test passes
```

**3. Incremental loop** — for each remaining behaviour:
```
RED:   Write next test → fails
GREEN: Minimum code to pass → passes
```

Rules:
- One test at a time
- Only enough code to pass the current test
- Does not anticipate future tests
- Tests focused on observable behaviour

**4. Refactor** — only after all tests pass:
- Extract duplication
- Deepen modules (move complexity behind simple interfaces)
- Apply SOLID where natural
- Run tests after each refactoring step

**Never refactor while RED.** Reach GREEN first.

### Per-cycle checklist

```
[ ] Test describes behaviour, not implementation
[ ] Test uses only public interface
[ ] Test would survive internal refactoring
[ ] Code is minimum for this test
[ ] No speculative features added
```

## Usage example

```
I want to implement a user search function by email. Can be exact or partial.

/tdd
```

The agent will plan: "Which behaviours matter? Exact search finds one user. Partial search returns multiple. Non-existent email returns empty. Which interface — `findUser(email: string): User | null` or something else?" — then implement one test at a time.

## Tips

- You can't test everything — confirm with the agent which behaviours are most critical
- Integration tests are preferable to unit tests with heavy mocks — they exercise real behaviour
- Use the project's domain glossary in test names to maintain consistency
