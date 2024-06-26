#include "irods_hasher_factory.hpp"
#include "checksum.hpp"
#include "MD5Strategy.hpp"
#include "SHA256Strategy.hpp"
#include "SHA512Strategy.hpp"
#include "ADLER32Strategy.hpp"
#include "SHA1Strategy.hpp"
#include "irods/rodsErrorTable.h"
#include <sstream>
#include <boost/unordered_map.hpp>

extern "C" {
  #include "globus_gridftp_server.h"
}

namespace irods::globus {

    namespace {
        const SHA256Strategy _sha256;
        const SHA512Strategy _sha512;
        const ADLER32Strategy _adler32;
        const MD5Strategy _md5;
        const SHA1Strategy _sha1;

        auto make_map() {
            boost::unordered_map<const std::string, const HashStrategy*> map;
            map[ SHA256_NAME ] = &_sha256;
            map[ SHA512_NAME ] = &_sha512;
            map[ MD5_NAME ] = &_md5;
            map[ ADLER32_NAME ] = &_adler32;
            map[ SHA1_NAME ] = &_sha1;
            return map;
        }

    };

    error
    getHasher( const std::string& _name, Hasher& _hasher ) {

        const auto _strategies{ make_map() };

        auto it = _strategies.find( _name );
        if ( _strategies.end() == it ) {
            std::stringstream msg;
            msg << "Unknown hashing scheme [" << _name << "]";
            return ERROR( SYS_INVALID_INPUT_PARAM, msg.str() );
        }
        _hasher.init( it->second );
        return SUCCESS();
    }

    error
    get_hash_scheme_from_checksum(
        const std::string& _chksum,
        std::string&       _scheme ) {

        const auto _strategies{ make_map() };

        if ( _chksum.empty() ) {
            return ERROR(
                       SYS_INVALID_INPUT_PARAM,
                       "empty chksum string" );
        }
        for ( const auto& [key, strategy] : _strategies) {
            if ( strategy->isChecksum( _chksum ) ) {
                _scheme = strategy->name();
                return SUCCESS();
            }
        }
        return ERROR(
                   SYS_INVALID_INPUT_PARAM,
                   "hash scheme not found" );

    } // get_hasher_scheme_from_checksum

}; // namespace irods::globus


