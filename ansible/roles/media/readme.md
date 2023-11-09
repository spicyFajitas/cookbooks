# Media

## Overview

This is for my ... DVD's...

## Known Issues

[https://github.com/linuxserver/docker-radarr/issues/204](https://github.com/linuxserver/docker-radarr/issues/204)

```
System.Net.Http.HttpRequestException: Connection refused (api.radarr.video:443): Connection refused (api.radarr.video:443)


System.Net.Http.HttpRequestException: Connection refused (api.radarr.video:443)
 ---> System.Net.Sockets.SocketException (111): Connection refused
   at System.Net.Sockets.Socket.AwaitableSocketAsyncEventArgs.ThrowException(SocketError error, CancellationToken cancellationToken)
   at System.Net.Sockets.Socket.AwaitableSocketAsyncEventArgs.System.Threading.Tasks.Sources.IValueTaskSource.GetResult(Int16 token)
   at System.Net.Sockets.Socket.<ConnectAsync>g__WaitForConnectWithCancellation|277_0(AwaitableSocketAsyncEventArgs saea, ValueTask connectTask, CancellationToken cancellationToken)
   at NzbDrone.Common.Http.Dispatchers.ManagedHttpDispatcher.attemptConnection(AddressFamily addressFamily, SocketsHttpConnectionContext context, CancellationToken cancellationToken) in ./Radarr.Common/Http/Dispatchers/ManagedHttpDispatcher.cs:line 302
   at NzbDrone.Common.Http.Dispatchers.ManagedHttpDispatcher.onConnect(SocketsHttpConnectionContext context, CancellationToken cancellationToken) in ./Radarr.Common/Http/Dispatchers/ManagedHttpDispatcher.cs:line 278
   at System.Net.Http.HttpConnectionPool.ConnectToTcpHostAsync(String host, Int32 port, HttpRequestMessage initialRequest, Boolean async, CancellationToken cancellationToken)
   --- End of inner exception stack trace ---
   at System.Net.Http.HttpConnectionPool.ConnectToTcpHostAsync(String host, Int32 port, HttpRequestMessage initialRequest, Boolean async, CancellationToken cancellationToken)
   at System.Net.Http.HttpConnectionPool.ConnectAsync(HttpRequestMessage request, Boolean async, CancellationToken cancellationToken)
   at System.Net.Http.HttpConnectionPool.AddHttp2ConnectionAsync(HttpRequestMessage request)
   at System.Threading.Tasks.TaskCompletionSourceWithCancellation`1.WaitWithCancellationAsync(CancellationToken cancellationToken)
   at System.Net.Http.HttpConnectionPool.GetHttp2ConnectionAsync(HttpRequestMessage request, Boolean async, CancellationToken cancellationToken)
   at System.Net.Http.HttpConnectionPool.SendWithVersionDetectionAndRetryAsync(HttpRequestMessage request, Boolean async, Boolean doRequestAuth, CancellationToken cancellationToken)
   at System.Net.Http.AuthenticationHelper.SendWithAuthAsync(HttpRequestMessage request, Uri authUri, Boolean async, ICredentials credentials, Boolean preAuthenticate, Boolean isProxyAuth, Boolean doRequestAuth, HttpConnectionPool pool, CancellationToken cancellationToken)
   at System.Net.Http.DiagnosticsHandler.SendAsyncCore(HttpRequestMessage request, Boolean async, CancellationToken cancellationToken)
   at System.Net.Http.DecompressionHandler.SendAsync(HttpRequestMessage request, Boolean async, CancellationToken cancellationToken)
   at System.Net.Http.HttpClient.<SendAsync>g__Core|83_0(HttpRequestMessage request, HttpCompletionOption completionOption, CancellationTokenSource cts, Boolean disposeCts, CancellationTokenSource pendingRequestsCts, CancellationToken originalCancellationToken)
   at NzbDrone.Common.Http.Dispatchers.ManagedHttpDispatcher.GetResponseAsync(HttpRequest request, CookieContainer cookies) in ./Radarr.Common/Http/Dispatchers/ManagedHttpDispatcher.cs:line 105
   at NzbDrone.Common.Http.HttpClient.ExecuteRequestAsync(HttpRequest request, CookieContainer cookieContainer) in ./Radarr.Common/Http/HttpClient.cs:line 157
   at NzbDrone.Common.Http.HttpClient.ExecuteAsync(HttpRequest request) in ./Radarr.Common/Http/HttpClient.cs:line 70
   at NzbDrone.Common.Http.HttpClient.GetAsync[T](HttpRequest request) in ./Radarr.Common/Http/HttpClient.cs:line 333
   at NzbDrone.Common.Http.HttpClient.Get[T](HttpRequest request) in ./Radarr.Common/Http/HttpClient.cs:line 341
   at NzbDrone.Core.MetadataSource.SkyHook.SkyHookProxy.SearchForNewMovie(String title) in ./Radarr.Core/MetadataSource/SkyHook/SkyHookProxy.cs:line 485
Close
```

"I have found the problem it was Ad Blocking on Unifi Firewall."

~ SBerg1980 - GitHub

## Solution

Turn off Unifi ad blocker.
