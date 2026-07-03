/// Platform environment access used by [Env].
library;

export 'env_source_stub.dart'
    if (dart.library.io) 'env_source_io.dart'
    show platformEnvironmentValue, readEnvFile;
