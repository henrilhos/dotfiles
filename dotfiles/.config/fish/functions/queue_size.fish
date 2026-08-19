function queue_size --description 'Tamanho de uma fila: queue_size <nome>'
    vendor/bin/sail artisan tinker --execute="echo Illuminate\Support\Facades\Queue::size('$argv[1]') . PHP_EOL;"
end
