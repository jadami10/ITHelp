$(document).ready(function() {
  try {
    Parse.initialize("Dxf9sHTC4H9iQoYP7FUPmkX8o99KTTJ01O1tBhjK", "oXnaI5OgVYPggkBhyOkxhhI81eb4p9kvSU4a7fRr");
    getAvailableRequests();
    subscribeToRequests();
  } catch(err) {
    alert("TODO: parse not initizlized");
  }

  try {
    pb = PUBNUB({
      subscribe_key: 'sub-c-8e935f6a-6eb4-11e5-95b8-0619f8945a4f',
      secret_key: 'sec-c-OTQyNjQzZDEtMGUzZC00OGU1LTk3OGQtMmRlNTQyY2Y2ZGNh',
      ssl: true
    });
  } catch (err) {
    alert("TODO: not subscribed to request channel")
  }

  // alert(pb)
});