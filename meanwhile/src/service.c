
#include "channel.h"
#include "message.h"
#include "mw_debug.h"
#include "service.h"


/* I tried to be explicit with the g_return_* calls, to make the debug
   logging a bit more sensible. Hence all the explicit "foo != NULL"
   checks. */

void mwService_recvChannelCreate(struct mwService *s, struct mwChannel *chan,
				 struct mwMsgChannelCreate *msg) {

  /* ensure none are null, ensure that the service and channel belong
     to the same session, and ensure that the message belongs on the
     channel */
  g_return_if_fail(s != NULL);
  g_return_if_fail(chan != NULL);
  g_return_if_fail(msg != NULL);
  g_return_if_fail(s->session == mwChannel_getSession(chan));
  g_return_if_fail(mwChannel_getId(chan) == msg->channel);

  if(s->recv_channelCreate)
    s->recv_channelCreate(s, chan, msg);
}


void mwService_recvChannelAccept(struct mwService *s, struct mwChannel *chan,
				 struct mwMsgChannelAccept *msg) {

  /* ensure none are null, ensure that the service and channel belong
     to the same session, and ensure that the message belongs on the
     channel */
  g_return_if_fail(s != NULL);
  g_return_if_fail(chan != NULL);
  g_return_if_fail(msg != NULL);
  g_return_if_fail(s->session == mwChannel_getSession(chan));
  g_return_if_fail(mwChannel_getId(chan) == msg->head.channel);

  if(s->recv_channelAccept)
    s->recv_channelAccept(s, chan, msg);
}


void mwService_recvChannelDestroy(struct mwService *s, struct mwChannel *chan,
				  struct mwMsgChannelDestroy *msg) {

  /* ensure none are null, ensure that the service and channel belong
     to the same session, and ensure that the message belongs on the
     channel */
  g_return_if_fail(s != NULL);
  g_return_if_fail(chan != NULL);
  g_return_if_fail(msg != NULL);
  g_return_if_fail(s->session == mwChannel_getSession(chan));
  g_return_if_fail(mwChannel_getId(chan) == msg->head.channel);

  if(s->recv_channelDestroy)
    s->recv_channelDestroy(s, chan, msg);
}


void mwService_recv(struct mwService *s, struct mwChannel *chan,
		    guint16 msg_type, struct mwOpaque *data) {

  /* ensure that none are null. data len should be something
     greater-than zero, as empty messages are supposed to be filtered
     at the session level. ensure that the service and channel belong
     to the same session */
  g_return_if_fail(s != NULL);
  g_return_if_fail(chan != NULL);
  g_return_if_fail(data != NULL);
  g_return_if_fail(data->len > 0);
  g_return_if_fail(s->session == mwChannel_getSession(chan));

  /*
  g_message("mwService_recv: session = %p, service = %p, b = %p, n = %u",
	    mwService_getSession(s), s, data->data, data->len);
  */

  if(s->recv)
    s->recv(s, chan, msg_type, data);
}


guint32 mwService_getType(struct mwService *s) {
  g_return_val_if_fail(s != NULL, 0x00);
  return s->type;
}


const char *mwService_getName(struct mwService *s) {
  g_return_val_if_fail(s != NULL, NULL);
  g_return_val_if_fail(s->get_name != NULL, NULL);

  return s->get_name(s);
}


const char *mwService_getDesc(struct mwService *s) {
  g_return_val_if_fail(s != NULL, NULL);
  g_return_val_if_fail(s->get_desc != NULL, NULL);

  return s->get_desc(s);
}


struct mwSession *mwService_getSession(struct mwService *s) {
  g_return_val_if_fail(s != NULL, NULL);
  return s->session;
}


void mwService_init(struct mwService *srvc, struct mwSession *sess,
		    guint32 type) {

  /* ensure nothing is null, and there's no such thing as a zero
     service type */
  g_return_if_fail(srvc != NULL);
  g_return_if_fail(sess != NULL);
  g_return_if_fail(type != 0x00);

  srvc->session = sess;
  srvc->type = type;
  srvc->state = mwServiceState_STOPPED;
}


enum mwServiceState mwService_getState(struct mwService *srvc) {
  g_return_val_if_fail(srvc != NULL, mwServiceState_STOPPED);
  return srvc->state;
}


void mwService_start(struct mwService *srvc) {
  g_return_if_fail(srvc != NULL);

  if(! MW_SERVICE_IS_STOPPED(srvc))
    return;

  srvc->state = mwServiceState_STARTING;
  g_message("starting service %s", NSTR(mwService_getName(srvc)));

  if(srvc->start) {
    srvc->start(srvc);
  } else {
    mwService_started(srvc);
  }
}


void mwService_started(struct mwService *srvc) {
  g_return_if_fail(srvc != NULL);

  srvc->state = mwServiceState_STARTED;
  g_message("started service %s", NSTR(mwService_getName(srvc)));
}


void mwService_error(struct mwService *srvc) {
  g_return_if_fail(srvc != NULL);

  if(MW_SERVICE_IS_DEAD(srvc))
    return;

  srvc->state = mwServiceState_ERROR;
  g_message("error in service %s", NSTR(mwService_getName(srvc)));

  if(srvc->stop) {
    srvc->stop(srvc);
  } else {
    mwService_stopped(srvc);
  }
}


void mwService_stop(struct mwService *srvc) {
  g_return_if_fail(srvc != NULL);

  if(MW_SERVICE_IS_DEAD(srvc))
    return;

  srvc->state = mwServiceState_STOPPING;
  g_message("stopping service %s", NSTR(mwService_getName(srvc)));

  if(srvc->stop) {
    srvc->stop(srvc);
  } else {
    mwService_stopped(srvc);
  }
}


void mwService_stopped(struct mwService *srvc) {
  g_return_if_fail(srvc != NULL);

  if(srvc->state != mwServiceState_STOPPED) {
    srvc->state = mwServiceState_STOPPED;
    g_message("stopped service %s", NSTR(mwService_getName(srvc)));
  }
}


void mwService_free(struct mwService *srvc) {
  g_return_if_fail(srvc != NULL);

  mwService_stop(srvc);

  if(srvc->clear)
    srvc->clear(srvc);

  g_free(srvc);
}

