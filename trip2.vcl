#
# This is an example VCL file for Varnish.
#
# It does not do anything by default, delegating control to the
# builtin VCL. The builtin VCL is called when there is no explicit
# return statement.
#
# See the VCL chapters in the Users Guide at https://www.varnish-cache.org/docs/
# and http://varnish-cache.org/trac/wiki/VCLExamples for more examples.

# Marker to tell the VCL compiler that this VCL has been adapted to the
# new 4.0 format.
vcl 4.0;

backend default {

    .host = "127.0.0.1";
    .port = "8080";

}

sub vcl_recv {

    if (req.method == "PURGE") {
        return (purge);
    }
 
    if (req.url ~ "^/(login|logout)") { 
        return (pass);
    }

}

sub vcl_backend_response {

    if (beresp.http.X-Authenticated == "false") {
        unset beresp.http.set-cookie;
    }

}

sub vcl_deliver {

}
