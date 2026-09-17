export function ignoredHoneybadgerNotice(notice) {
  if (notice?.name === 'TurnstileError') return true

  return notice?.name === 'window.onunhandledrejection' &&
    notice?.message === 'UnhandledPromiseRejectionWarning: Unspecified reason' &&
    notice?.stack?.includes('webkit-masked-url://hidden/')
}

export function installHoneybadgerFilter(honeybadger) {
  honeybadger.beforeNotify((notice) => {
    if (ignoredHoneybadgerNotice(notice)) return false
  })
}
