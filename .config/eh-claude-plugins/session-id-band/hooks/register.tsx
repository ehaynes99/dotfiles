import type { Register } from 'claude-code'

export const register: Register = on => {
  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    // Other mods share this slot; next(e) rejects when nothing answers beneath.
    const below = await next(e).catch(() => undefined)
    if (e.props.hasSurvey) return below
    const { Box, Text } = $.ui.resolve(e)
    const mine = <Text dimColor>session {await $.session.id()}</Text>
    return below ? <Box flexDirection="column">{mine}{below}</Box> : mine
  }).catch(($, e, next) => next(e))
}
