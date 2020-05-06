#[derive(Clone, Debug, Eq, PartialEq)]
pub enum Error {
    GeneralError,
    FromHexError,
    ElGamalConversionError,
    // Web3Error
    Web3ErrorIo,
    Web3ErrorRpc,
    Web3ErrorUnreachable,
    Web3ErrorDecoder,
    Web3ErrorInvalidResponse,
    Web3ErrorTransport,
    Web3ErrorInternal,
    // Web3ErrorContract
    Web3ErrorContractInvalidOutputType,
    Web3ErrorContractAbi,
    Web3ErrorContractApi,
    // EthAbiError
    EthAbiError,
    EthAbiErrorInvalidName,
    EthAbiErrorInvalidData,
    EthAbiErrorSerdeJson,
    EthAbiErrorParseInt,
    EthAbiErrorUtf8,
    EthAbiErrorHex,
    EthAbiErrorOther,
}

impl From<()> for Error {
    fn from(e: ()) -> Error {
        match e {
            () => Error::GeneralError,
        }
    }
}

impl From<web3::contract::Error> for Error {
    fn from(e: web3::contract::Error) -> Error {
        match e {
            web3::contract::Error::InvalidOutputType(_) => {
                Error::Web3ErrorContractInvalidOutputType
            }
            web3::contract::Error::Abi(_) => Error::Web3ErrorContractAbi,
            web3::contract::Error::Api(_) => Error::Web3ErrorContractApi,
        }
    }
}

impl From<web3::error::Error> for Error {
    fn from(e: web3::error::Error) -> Error {
        match e {
            web3::error::Error::Rpc(_) => Error::Web3ErrorRpc,
            web3::error::Error::Io(_) => Error::Web3ErrorIo,
            web3::error::Error::Unreachable => Error::Web3ErrorUnreachable,
            web3::error::Error::Decoder(_) => Error::Web3ErrorDecoder,
            web3::error::Error::InvalidResponse(_) => Error::Web3ErrorInvalidResponse,
            web3::error::Error::Transport(_) => Error::Web3ErrorTransport,
            web3::error::Error::Internal => Error::Web3ErrorInternal,
        }
    }
}

impl From<ethabi::Error> for Error {
    fn from(e: ethabi::Error) -> Error {
        match e {
            ethabi::Error::InvalidName(_) => Error::EthAbiErrorInvalidName,
            ethabi::Error::InvalidData => Error::EthAbiErrorInvalidData,
            ethabi::Error::SerdeJson(_) => Error::EthAbiErrorSerdeJson,
            ethabi::Error::ParseInt(_) => Error::EthAbiErrorParseInt,
            ethabi::Error::Utf8(_) => Error::EthAbiErrorUtf8,
            ethabi::Error::Hex(_) => Error::EthAbiErrorHex,
            ethabi::Error::Other(_) => Error::EthAbiErrorOther,
        }
    }
}

impl From<rustc_hex::FromHexError> for Error {
    fn from(e: rustc_hex::FromHexError) -> Error {
        match e {
            rustc_hex::FromHexError::InvalidHexCharacter(_, _) => Error::FromHexError,
            rustc_hex::FromHexError::InvalidHexLength => Error::FromHexError,
        }
    }
}
