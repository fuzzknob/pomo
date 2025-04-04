import { z } from 'zod'

import { eq, tables, useDrizzle } from '~/server/services/drizzle'
import { sendEvent } from '~/server/services/event'
import { TimerEvent, TimerStatus, type User } from '~/types/types'

const pauseTimerSchema = z.object({
  elapsedPrePause: z.number(),
  successionCount: z.number(),
  totalWorkTime: z.number(),
  totalBreakTime: z.number(),
})
export default defineEventHandler(async (event) => {
  if (!event.context.user) {
    setResponseStatus(event, 401)
    return {
      message: 'not logged in',
    }
  }
  const result = await readValidatedBody(event, pauseTimerSchema.safeParse)
  if (!result.success) {
    setResponseStatus(event, 400)
    return { message: 'There was an validation error', errors: result.error.issues }
  }
  const user = event.context.user as User
  const db = useDrizzle()
  const timer = await db
    .query
    .timers
    .findFirst({
      where: (timers, { eq }) => eq(timers.userId, user.id),
    })
  if (!timer) {
    setResponseStatus(event, 400)
    return { message: 'There is no running timer' }
  }
  // if (timer.status !== TimerStatus.Working) {
  //   setResponseStatus(event, 400)
  //   return { message: 'Timer can only be paused while the status is WORKING' }
  // }
  const { data } = result
  await db.update(tables.timers).set({
    status: TimerStatus.Paused,
    elapsedPrePause: data.elapsedPrePause,
    successionCount: data.successionCount,
    workTillStatusChange: data.totalWorkTime,
    breakTillStatusChange: data.totalBreakTime,
  }).where(eq(tables.timers.userId, user.id))
  if (timer != null) {
    await sendEvent(event, user, {
      event: TimerEvent.Pause,
      timer: {
        status: TimerStatus.Paused,
        elapsedPrePause: data.elapsedPrePause,
        successionCount: data.successionCount,
        totalWorkTime: data.totalWorkTime,
        totalBreakTime: data.totalBreakTime,
        startTime: timer.startTime,
      },
    })
  }
  return {
    message: 'Paused Timer',
  }
})
