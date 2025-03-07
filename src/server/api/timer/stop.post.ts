import { z } from 'zod'
import { tables, useDrizzle } from '~/server/services/drizzle'
import { type User, TimerStatus } from '~/types/types'

const stopTimerSchema = z.object({
  endTime: z.coerce.date(),
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
  const result = await readValidatedBody(event, stopTimerSchema.safeParse)
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
  const { data } = result
  await db.update(tables.timers).set({
    status: TimerStatus.Stopped,
    workTillStatusChange: data.totalWorkTime,
    breakTillStatusChange: data.totalBreakTime,
  })
  // TODO: send websocket event
  await db.insert(tables.histories).values({
    startTime: timer.timerStartedAt,
    endTime: data.endTime,
    totalWorkTime: data.totalWorkTime,
    totalBreakTime: data.totalBreakTime,
    userId: user.id,
  })
  return {
    message: 'Stopped Timer',
  }
})
