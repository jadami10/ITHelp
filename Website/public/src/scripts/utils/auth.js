export function requireAuth(nextState, replaceState) {
  if (Parse.User.current() == null) {
    replaceState({ nextPathname: nextState.location.pathname }, '/login')
  }
}

export function checkAuth(nextState, replaceState) {
  if (Parse.User.current() != null) {
    replaceState({ nextPathname: nextState.location.pathname }, '/app')
  }
}
