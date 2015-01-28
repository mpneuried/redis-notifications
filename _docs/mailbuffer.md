# MailBuffer

## Requirement

|send_at|created|user_id|msg_id|message|
|--:|--:|:--:|:--:|--:|
|2014-01-29 17:00|2014-01-28 15:35|ABCD1|1|Lorem Ipsum|
|2014-01-29 09:00|2014-01-28 15:32|WXYZ1|2|Dolor Si Amet|
|2014-01-29 09:00|2014-01-28 19:36|WXYZ1|3|Lorem Ipsum|
|2014-01-29 17:00|2014-01-27 08:18|ABCD1|4|Hello World|

```sql
SELECT *
FROM MailBuffer
WHERE send_at < now()
ORDER BY user_id, created
``` 

## redis solution

Set of users that will receive a mail (pending messages in buffer)

**ZSET `users_with_messages` `{send_at}` `{user_id}`**

* `send_at` timestamp in seconds
* `user_id` user_id

Call: `ZRANGEBYSCORE users_with_messages 0 1422452406`

**LPUSH `msgs:{user_id}` `{message-JSON}`**

* `user_id` user_id
* `message-JSON` stringified message data

Call: `LRANGE msgs:ABCD1 0 -1`




--- 

