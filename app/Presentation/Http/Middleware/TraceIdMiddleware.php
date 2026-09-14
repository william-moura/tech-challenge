<?php

namespace App\Presentation\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Log;

class TraceIdMiddleware
{
    public function handle(Request $request, Closure $next)
    {
        $traceId = $request->header('X-Trace-Id') ?? (string) Str::uuid();

        // Injeta o trace_id no contexto do log estruturado
        Log::shareContext([
            'trace_id' => $traceId,
            'url'      => $request->fullUrl(),
            'method'   => $request->method(),
        ]);

        $response = $next($request);
        $response->headers->set('X-Trace-Id', $traceId);

        return $response;
    }
}