package com.opendatagroup.fastscore.util

import javax.net.ssl.{ SSLContext, TrustManager, X509TrustManager, HostnameVerifier, HttpsURLConnection, SSLSession }

object SSLVerify {
    def disableSSLVerify(): Unit = {
      val trustAllCerts: Array[TrustManager] = Array(new X509TrustManager() {
        def getAcceptedIssuers(): Array[java.security.cert.X509Certificate] =
          null

        def checkClientTrusted(certs: Array[java.security.cert.X509Certificate],
                               authType: String): Unit = {}

        def checkServerTrusted(certs: Array[java.security.cert.X509Certificate],
                               authType: String): Unit = {}
      })

      val sc: SSLContext = SSLContext.getInstance("SSL")
      sc.init(null, trustAllCerts, new java.security.SecureRandom())
      HttpsURLConnection.setDefaultSSLSocketFactory(sc.getSocketFactory)

      val allHostsValid: HostnameVerifier = new HostnameVerifier() {
        def verify(hostname: String, session: SSLSession): Boolean = true
      }

      HttpsURLConnection.setDefaultHostnameVerifier(allHostsValid)
    }
}
