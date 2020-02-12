// This file is LGPL3 Licensed

/**
 * @title Elliptic curve operations on twist points for alt_bn128
 * @author Mustafa Al-Bassam (mus@musalbas.com)
 * @dev Homepage: https://github.com/musalbas/solidity-BN256G2
 */

library BN256G2 {
    uint256 internal constant FIELD_MODULUS = 0x30644e72e131a029b85045b68181585d97816a916871ca8d3c208c16d87cfd47;
    uint256 internal constant TWISTBX = 0x2b149d40ceb8aaae81be18991be06ac3b5b4c5e559dbefa33267e6dc24a138e5;
    uint256 internal constant TWISTBY = 0x9713b03af0fed4cd2cafadeed8fdf4a74fa084e52d1852e4a2bd0685c315d2;
    uint internal constant PTXX = 0;
    uint internal constant PTXY = 1;
    uint internal constant PTYX = 2;
    uint internal constant PTYY = 3;
    uint internal constant PTZX = 4;
    uint internal constant PTZY = 5;

    /**
     * @notice Add two twist points
     * @param pt1xx Coefficient 1 of x on point 1
     * @param pt1xy Coefficient 2 of x on point 1
     * @param pt1yx Coefficient 1 of y on point 1
     * @param pt1yy Coefficient 2 of y on point 1
     * @param pt2xx Coefficient 1 of x on point 2
     * @param pt2xy Coefficient 2 of x on point 2
     * @param pt2yx Coefficient 1 of y on point 2
     * @param pt2yy Coefficient 2 of y on point 2
     * @return (pt3xx, pt3xy, pt3yx, pt3yy)
     */
    function ECTwistAdd(
        uint256 pt1xx, uint256 pt1xy,
        uint256 pt1yx, uint256 pt1yy,
        uint256 pt2xx, uint256 pt2xy,
        uint256 pt2yx, uint256 pt2yy
    ) public view returns (
        uint256, uint256,
        uint256, uint256
    ) {
        if (
            pt1xx == 0 && pt1xy == 0 &&
            pt1yx == 0 && pt1yy == 0
        ) {
            if (!(
                pt2xx == 0 && pt2xy == 0 &&
                pt2yx == 0 && pt2yy == 0
            )) {
                assert(_isOnCurve(
                    pt2xx, pt2xy,
                    pt2yx, pt2yy
                ));
            }
            return (
                pt2xx, pt2xy,
                pt2yx, pt2yy
            );
        } else if (
            pt2xx == 0 && pt2xy == 0 &&
            pt2yx == 0 && pt2yy == 0
        ) {
            assert(_isOnCurve(
                pt1xx, pt1xy,
                pt1yx, pt1yy
            ));
            return (
                pt1xx, pt1xy,
                pt1yx, pt1yy
            );
        }

        assert(_isOnCurve(
            pt1xx, pt1xy,
            pt1yx, pt1yy
        ));
        assert(_isOnCurve(
            pt2xx, pt2xy,
            pt2yx, pt2yy
        ));

        uint256[6] memory pt3 = _ECTwistAddJacobian(
            pt1xx, pt1xy,
            pt1yx, pt1yy,
            1,     0,
            pt2xx, pt2xy,
            pt2yx, pt2yy,
            1,     0
        );

        return _fromJacobian(
            pt3[PTXX], pt3[PTXY],
            pt3[PTYX], pt3[PTYY],
            pt3[PTZX], pt3[PTZY]
        );
    }

    /**
     * @notice Multiply a twist point by a scalar
     * @param s     Scalar to multiply by
     * @param pt1xx Coefficient 1 of x
     * @param pt1xy Coefficient 2 of x
     * @param pt1yx Coefficient 1 of y
     * @param pt1yy Coefficient 2 of y
     * @return (pt2xx, pt2xy, pt2yx, pt2yy)
     */
    function ECTwistMul(
        uint256 s,
        uint256 pt1xx, uint256 pt1xy,
        uint256 pt1yx, uint256 pt1yy
    ) public view returns (
        uint256, uint256,
        uint256, uint256
    ) {
        uint256 pt1zx = 1;
        if (
            pt1xx == 0 && pt1xy == 0 &&
            pt1yx == 0 && pt1yy == 0
        ) {
            pt1xx = 1;
            pt1yx = 1;
            pt1zx = 0;
        } else {
            assert(_isOnCurve(
                pt1xx, pt1xy,
                pt1yx, pt1yy
            ));
        }

        uint256[6] memory pt2 = _ECTwistMulJacobian(
            s,
            pt1xx, pt1xy,
            pt1yx, pt1yy,
            pt1zx, 0
        );

        return _fromJacobian(
            pt2[PTXX], pt2[PTXY],
            pt2[PTYX], pt2[PTYY],
            pt2[PTZX], pt2[PTZY]
        );
    }

    /**
     * @notice Get the field modulus
     * @return The field modulus
     */
    function GetFieldModulus() public pure returns (uint256) {
        return FIELD_MODULUS;
    }

    function submod(uint256 a, uint256 b, uint256 n) internal pure returns (uint256) {
        return addmod(a, n - b, n);
    }

    function _FQ2Mul(
        uint256 xx, uint256 xy,
        uint256 yx, uint256 yy
    ) internal pure returns (uint256, uint256) {
        return (
            submod(mulmod(xx, yx, FIELD_MODULUS), mulmod(xy, yy, FIELD_MODULUS), FIELD_MODULUS),
            addmod(mulmod(xx, yy, FIELD_MODULUS), mulmod(xy, yx, FIELD_MODULUS), FIELD_MODULUS)
        );
    }

    function _FQ2Muc(
        uint256 xx, uint256 xy,
        uint256 c
    ) internal pure returns (uint256, uint256) {
        return (
            mulmod(xx, c, FIELD_MODULUS),
            mulmod(xy, c, FIELD_MODULUS)
        );
    }

    function _FQ2Add(
        uint256 xx, uint256 xy,
        uint256 yx, uint256 yy
    ) internal pure returns (uint256, uint256) {
        return (
            addmod(xx, yx, FIELD_MODULUS),
            addmod(xy, yy, FIELD_MODULUS)
        );
    }

    function _FQ2Sub(
        uint256 xx, uint256 xy,
        uint256 yx, uint256 yy
    ) internal pure returns (uint256 rx, uint256 ry) {
        return (
            submod(xx, yx, FIELD_MODULUS),
            submod(xy, yy, FIELD_MODULUS)
        );
    }

    function _FQ2Div(
        uint256 xx, uint256 xy,
        uint256 yx, uint256 yy
    ) internal view returns (uint256, uint256) {
        (yx, yy) = _FQ2Inv(yx, yy);
        return _FQ2Mul(xx, xy, yx, yy);
    }

    function _FQ2Inv(uint256 x, uint256 y) internal view returns (uint256, uint256) {
        uint256 inv = _modInv(addmod(mulmod(y, y, FIELD_MODULUS), mulmod(x, x, FIELD_MODULUS), FIELD_MODULUS), FIELD_MODULUS);
        return (
            mulmod(x, inv, FIELD_MODULUS),
            FIELD_MODULUS - mulmod(y, inv, FIELD_MODULUS)
        );
    }

    function _isOnCurve(
        uint256 xx, uint256 xy,
        uint256 yx, uint256 yy
    ) internal pure returns (bool) {
        uint256 yyx;
        uint256 yyy;
        uint256 xxxx;
        uint256 xxxy;
        (yyx, yyy) = _FQ2Mul(yx, yy, yx, yy);
        (xxxx, xxxy) = _FQ2Mul(xx, xy, xx, xy);
        (xxxx, xxxy) = _FQ2Mul(xxxx, xxxy, xx, xy);
        (yyx, yyy) = _FQ2Sub(yyx, yyy, xxxx, xxxy);
        (yyx, yyy) = _FQ2Sub(yyx, yyy, TWISTBX, TWISTBY);
        return yyx == 0 && yyy == 0;
    }

    function _modInv(uint256 a, uint256 n) internal view returns (uint256 result) {
        bool success;
        assembly {
            let freemem := mload(0x40)
            mstore(freemem, 0x20)
            mstore(add(freemem,0x20), 0x20)
            mstore(add(freemem,0x40), 0x20)
            mstore(add(freemem,0x60), a)
            mstore(add(freemem,0x80), sub(n, 2))
            mstore(add(freemem,0xA0), n)
            success := staticcall(sub(gas, 2000), 5, freemem, 0xC0, freemem, 0x20)
            result := mload(freemem)
        }
        require(success);
    }

    function _fromJacobian(
        uint256 pt1xx, uint256 pt1xy,
        uint256 pt1yx, uint256 pt1yy,
        uint256 pt1zx, uint256 pt1zy
    ) internal view returns (
        uint256 pt2xx, uint256 pt2xy,
        uint256 pt2yx, uint256 pt2yy
    ) {
        uint256 invzx;
        uint256 invzy;
        (invzx, invzy) = _FQ2Inv(pt1zx, pt1zy);
        (pt2xx, pt2xy) = _FQ2Mul(pt1xx, pt1xy, invzx, invzy);
        (pt2yx, pt2yy) = _FQ2Mul(pt1yx, pt1yy, invzx, invzy);
    }

    function _ECTwistAddJacobian(
        uint256 pt1xx, uint256 pt1xy,
        uint256 pt1yx, uint256 pt1yy,
        uint256 pt1zx, uint256 pt1zy,
        uint256 pt2xx, uint256 pt2xy,
        uint256 pt2yx, uint256 pt2yy,
        uint256 pt2zx, uint256 pt2zy) internal pure returns (uint256[6] memory pt3) {
            if (pt1zx == 0 && pt1zy == 0) {
                (
                    pt3[PTXX], pt3[PTXY],
                    pt3[PTYX], pt3[PTYY],
                    pt3[PTZX], pt3[PTZY]
                ) = (
                    pt2xx, pt2xy,
                    pt2yx, pt2yy,
                    pt2zx, pt2zy
                );
                return pt3;
            } else if (pt2zx == 0 && pt2zy == 0) {
                (
                    pt3[PTXX], pt3[PTXY],
                    pt3[PTYX], pt3[PTYY],
                    pt3[PTZX], pt3[PTZY]
                ) = (
                    pt1xx, pt1xy,
                    pt1yx, pt1yy,
                    pt1zx, pt1zy
                );
                return pt3;
            }

            (pt2yx,     pt2yy)     = _FQ2Mul(pt2yx, pt2yy, pt1zx, pt1zy); // U1 = y2 * z1
            (pt3[PTYX], pt3[PTYY]) = _FQ2Mul(pt1yx, pt1yy, pt2zx, pt2zy); // U2 = y1 * z2
            (pt2xx,     pt2xy)     = _FQ2Mul(pt2xx, pt2xy, pt1zx, pt1zy); // V1 = x2 * z1
            (pt3[PTZX], pt3[PTZY]) = _FQ2Mul(pt1xx, pt1xy, pt2zx, pt2zy); // V2 = x1 * z2

            if (pt2xx == pt3[PTZX] && pt2xy == pt3[PTZY]) {
                if (pt2yx == pt3[PTYX] && pt2yy == pt3[PTYY]) {
                    (
                        pt3[PTXX], pt3[PTXY],
                        pt3[PTYX], pt3[PTYY],
                        pt3[PTZX], pt3[PTZY]
                    ) = _ECTwistDoubleJacobian(pt1xx, pt1xy, pt1yx, pt1yy, pt1zx, pt1zy);
                    return pt3;
                }
                (
                    pt3[PTXX], pt3[PTXY],
                    pt3[PTYX], pt3[PTYY],
                    pt3[PTZX], pt3[PTZY]
                ) = (
                    1, 0,
                    1, 0,
                    0, 0
                );
                return pt3;
            }

            (pt2zx,     pt2zy)     = _FQ2Mul(pt1zx, pt1zy, pt2zx,     pt2zy);     // W = z1 * z2
            (pt1xx,     pt1xy)     = _FQ2Sub(pt2yx, pt2yy, pt3[PTYX], pt3[PTYY]); // U = U1 - U2
            (pt1yx,     pt1yy)     = _FQ2Sub(pt2xx, pt2xy, pt3[PTZX], pt3[PTZY]); // V = V1 - V2
            (pt1zx,     pt1zy)     = _FQ2Mul(pt1yx, pt1yy, pt1yx,     pt1yy);     // V_squared = V * V
            (pt2yx,     pt2yy)     = _FQ2Mul(pt1zx, pt1zy, pt3[PTZX], pt3[PTZY]); // V_squared_times_V2 = V_squared * V2
            (pt1zx,     pt1zy)     = _FQ2Mul(pt1zx, pt1zy, pt1yx,     pt1yy);     // V_cubed = V * V_squared
            (pt3[PTZX], pt3[PTZY]) = _FQ2Mul(pt1zx, pt1zy, pt2zx,     pt2zy);     // newz = V_cubed * W
            (pt2xx,     pt2xy)     = _FQ2Mul(pt1xx, pt1xy, pt1xx,     pt1xy);     // U * U
            (pt2xx,     pt2xy)     = _FQ2Mul(pt2xx, pt2xy, pt2zx,     pt2zy);     // U * U * W
            (pt2xx,     pt2xy)     = _FQ2Sub(pt2xx, pt2xy, pt1zx,     pt1zy);     // U * U * W - V_cubed
            (pt2zx,     pt2zy)     = _FQ2Muc(pt2yx, pt2yy, 2);                    // 2 * V_squared_times_V2
            (pt2xx,     pt2xy)     = _FQ2Sub(pt2xx, pt2xy, pt2zx,     pt2zy);     // A = U * U * W - V_cubed - 2 * V_squared_times_V2
            (pt3[PTXX], pt3[PTXY]) = _FQ2Mul(pt1yx, pt1yy, pt2xx,     pt2xy);     // newx = V * A
            (pt1yx,     pt1yy)     = _FQ2Sub(pt2yx, pt2yy, pt2xx,     pt2xy);     // V_squared_times_V2 - A
            (pt1yx,     pt1yy)     = _FQ2Mul(pt1xx, pt1xy, pt1yx,     pt1yy);     // U * (V_squared_times_V2 - A)
            (pt1xx,     pt1xy)     = _FQ2Mul(pt1zx, pt1zy, pt3[PTYX], pt3[PTYY]); // V_cubed * U2
            (pt3[PTYX], pt3[PTYY]) = _FQ2Sub(pt1yx, pt1yy, pt1xx,     pt1xy);     // newy = U * (V_squared_times_V2 - A) - V_cubed * U2
    }

    function _ECTwistDoubleJacobian(
        uint256 pt1xx, uint256 pt1xy,
        uint256 pt1yx, uint256 pt1yy,
        uint256 pt1zx, uint256 pt1zy
    ) internal pure returns (
        uint256 pt2xx, uint256 pt2xy,
        uint256 pt2yx, uint256 pt2yy,
        uint256 pt2zx, uint256 pt2zy
    ) {
        (pt2xx, pt2xy) = _FQ2Muc(pt1xx, pt1xy, 3);            // 3 * x
        (pt2xx, pt2xy) = _FQ2Mul(pt2xx, pt2xy, pt1xx, pt1xy); // W = 3 * x * x
        (pt1zx, pt1zy) = _FQ2Mul(pt1yx, pt1yy, pt1zx, pt1zy); // S = y * z
        (pt2yx, pt2yy) = _FQ2Mul(pt1xx, pt1xy, pt1yx, pt1yy); // x * y
        (pt2yx, pt2yy) = _FQ2Mul(pt2yx, pt2yy, pt1zx, pt1zy); // B = x * y * S
        (pt1xx, pt1xy) = _FQ2Mul(pt2xx, pt2xy, pt2xx, pt2xy); // W * W
        (pt2zx, pt2zy) = _FQ2Muc(pt2yx, pt2yy, 8);            // 8 * B
        (pt1xx, pt1xy) = _FQ2Sub(pt1xx, pt1xy, pt2zx, pt2zy); // H = W * W - 8 * B
        (pt2zx, pt2zy) = _FQ2Mul(pt1zx, pt1zy, pt1zx, pt1zy); // S_squared = S * S
        (pt2yx, pt2yy) = _FQ2Muc(pt2yx, pt2yy, 4);            // 4 * B
        (pt2yx, pt2yy) = _FQ2Sub(pt2yx, pt2yy, pt1xx, pt1xy); // 4 * B - H
        (pt2yx, pt2yy) = _FQ2Mul(pt2yx, pt2yy, pt2xx, pt2xy); // W * (4 * B - H)
        (pt2xx, pt2xy) = _FQ2Muc(pt1yx, pt1yy, 8);            // 8 * y
        (pt2xx, pt2xy) = _FQ2Mul(pt2xx, pt2xy, pt1yx, pt1yy); // 8 * y * y
        (pt2xx, pt2xy) = _FQ2Mul(pt2xx, pt2xy, pt2zx, pt2zy); // 8 * y * y * S_squared
        (pt2yx, pt2yy) = _FQ2Sub(pt2yx, pt2yy, pt2xx, pt2xy); // newy = W * (4 * B - H) - 8 * y * y * S_squared
        (pt2xx, pt2xy) = _FQ2Muc(pt1xx, pt1xy, 2);            // 2 * H
        (pt2xx, pt2xy) = _FQ2Mul(pt2xx, pt2xy, pt1zx, pt1zy); // newx = 2 * H * S
        (pt2zx, pt2zy) = _FQ2Mul(pt1zx, pt1zy, pt2zx, pt2zy); // S * S_squared
        (pt2zx, pt2zy) = _FQ2Muc(pt2zx, pt2zy, 8);            // newz = 8 * S * S_squared
    }

    function _ECTwistMulJacobian(
        uint256 d,
        uint256 pt1xx, uint256 pt1xy,
        uint256 pt1yx, uint256 pt1yy,
        uint256 pt1zx, uint256 pt1zy
    ) internal pure returns (uint256[6] memory pt2) {
        while (d != 0) {
            if ((d & 1) != 0) {
                pt2 = _ECTwistAddJacobian(
                    pt2[PTXX], pt2[PTXY],
                    pt2[PTYX], pt2[PTYY],
                    pt2[PTZX], pt2[PTZY],
                    pt1xx, pt1xy,
                    pt1yx, pt1yy,
                    pt1zx, pt1zy);
            }
            (
                pt1xx, pt1xy,
                pt1yx, pt1yy,
                pt1zx, pt1zy
            ) = _ECTwistDoubleJacobian(
                pt1xx, pt1xy,
                pt1yx, pt1yy,
                pt1zx, pt1zy
            );

            d = d / 2;
        }
    }
}
// This file is MIT Licensed.
//
// Copyright 2017 Christian Reitwiessner
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
pragma solidity ^0.5.0;
library Pairing {
    struct G1Point {
        uint X;
        uint Y;
    }
    // Encoding of field elements is: X[0] * z + X[1]
    struct G2Point {
        uint[2] X;
        uint[2] Y;
    }
    /// @return the generator of G1
    function P1() pure internal returns (G1Point memory) {
        return G1Point(1, 2);
    }
    /// @return the generator of G2
    function P2() pure internal returns (G2Point memory) {
        return G2Point(
            [11559732032986387107991004021392285783925812861821192530917403151452391805634,
             10857046999023057135944570762232829481370756359578518086990519993285655852781],
            [4082367875863433681332203403145435568316851327593401208105741076214120093531,
             8495653923123431417604973247489272438418190587263600148770280649306958101930]
        );
    }
    /// @return the negation of p, i.e. p.addition(p.negate()) should be zero.
    function negate(G1Point memory p) pure internal returns (G1Point memory) {
        // The prime q in the base field F_q for G1
        uint q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
        if (p.X == 0 && p.Y == 0)
            return G1Point(0, 0);
        return G1Point(p.X, q - (p.Y % q));
    }
    /// @return the sum of two points of G1
    function addition(G1Point memory p1, G1Point memory p2) internal returns (G1Point memory r) {
        uint[4] memory input;
        input[0] = p1.X;
        input[1] = p1.Y;
        input[2] = p2.X;
        input[3] = p2.Y;
        bool success;
        assembly {
            success := call(sub(gas, 2000), 6, 0, input, 0xc0, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require(success);
    }
    /// @return the sum of two points of G2
    function addition(G2Point memory p1, G2Point memory p2) internal returns (G2Point memory r) {
        (r.X[1], r.X[0], r.Y[1], r.Y[0]) = BN256G2.ECTwistAdd(p1.X[1],p1.X[0],p1.Y[1],p1.Y[0],p2.X[1],p2.X[0],p2.Y[1],p2.Y[0]);
    }
    /// @return the product of a point on G1 and a scalar, i.e.
    /// p == p.scalar_mul(1) and p.addition(p) == p.scalar_mul(2) for all points p.
    function scalar_mul(G1Point memory p, uint s) internal returns (G1Point memory r) {
        uint[3] memory input;
        input[0] = p.X;
        input[1] = p.Y;
        input[2] = s;
        bool success;
        assembly {
            success := call(sub(gas, 2000), 7, 0, input, 0x80, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require (success);
    }
    /// @return the result of computing the pairing check
    /// e(p1[0], p2[0]) *  .... * e(p1[n], p2[n]) == 1
    /// For example pairing([P1(), P1().negate()], [P2(), P2()]) should
    /// return true.
    function pairing(G1Point[] memory p1, G2Point[] memory p2) internal returns (bool) {
        require(p1.length == p2.length);
        uint elements = p1.length;
        uint inputSize = elements * 6;
        uint[] memory input = new uint[](inputSize);
        for (uint i = 0; i < elements; i++)
        {
            input[i * 6 + 0] = p1[i].X;
            input[i * 6 + 1] = p1[i].Y;
            input[i * 6 + 2] = p2[i].X[0];
            input[i * 6 + 3] = p2[i].X[1];
            input[i * 6 + 4] = p2[i].Y[0];
            input[i * 6 + 5] = p2[i].Y[1];
        }
        uint[1] memory out;
        bool success;
        assembly {
            success := call(sub(gas, 2000), 8, 0, add(input, 0x20), mul(inputSize, 0x20), out, 0x20)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require(success);
        return out[0] != 0;
    }
    /// Convenience method for a pairing check for two pairs.
    function pairingProd2(G1Point memory a1, G2Point memory a2, G1Point memory b1, G2Point memory b2) internal returns (bool) {
        G1Point[] memory p1 = new G1Point[](2);
        G2Point[] memory p2 = new G2Point[](2);
        p1[0] = a1;
        p1[1] = b1;
        p2[0] = a2;
        p2[1] = b2;
        return pairing(p1, p2);
    }
    /// Convenience method for a pairing check for three pairs.
    function pairingProd3(
            G1Point memory a1, G2Point memory a2,
            G1Point memory b1, G2Point memory b2,
            G1Point memory c1, G2Point memory c2
    ) internal returns (bool) {
        G1Point[] memory p1 = new G1Point[](3);
        G2Point[] memory p2 = new G2Point[](3);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        return pairing(p1, p2);
    }
    /// Convenience method for a pairing check for four pairs.
    function pairingProd4(
            G1Point memory a1, G2Point memory a2,
            G1Point memory b1, G2Point memory b2,
            G1Point memory c1, G2Point memory c2,
            G1Point memory d1, G2Point memory d2
    ) internal returns (bool) {
        G1Point[] memory p1 = new G1Point[](4);
        G2Point[] memory p2 = new G2Point[](4);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p1[3] = d1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        p2[3] = d2;
        return pairing(p1, p2);
    }
}

contract Verifier {
    using Pairing for *;
    struct VerifyingKey {
        Pairing.G1Point a;
        Pairing.G2Point b;
        Pairing.G2Point gamma;
        Pairing.G2Point delta;
        Pairing.G1Point[] gamma_abc;
    }
    struct Proof {
        Pairing.G1Point a;
        Pairing.G2Point b;
        Pairing.G1Point c;
    }
    function verifyingKey() pure internal returns (VerifyingKey memory vk) {
        vk.a = Pairing.G1Point(uint256(0x16d61123a5cc30620e1ecd93d3348a89ed882c250e9cda6b26323440f196fd62), uint256(0x09190698ad7607cd053f655d5cf5cdd41d56a825ac9a7e3b2e6b19b3879e9e1a));
        vk.b = Pairing.G2Point([uint256(0x1ee4988224fc35ddb50d845384461459e9e7390a17aab1b48e840d8738a8d9c3), uint256(0x072690efc6b5dbe70463f4949b97c8bbfc9191ca7d1a000d2a75aef5a6990cf3)], [uint256(0x03bdd05f2d21ebbd014c5c4c6e91af1d647649ca3dcaf6f81a48c33a9ba16550), uint256(0x225356d0db8dc0795717f9f1d5f45e13d46dcd94ef891cae95fa673a41a06dd0)]);
        vk.gamma = Pairing.G2Point([uint256(0x22d9fe68f6bc19d4ae7b7dd8259291e42d4e3605e79ad0786d58d9d7c441db4d), uint256(0x2edd40e583deb660d6b97c56a11524f22c1591447546857747525127bbbdb2e1)], [uint256(0x1ddebf9819969129b856d1c2ba980242b2abf3fd260a6291900c4f3dd867e55b), uint256(0x039b5b5672c11d6e202b7567447fb6dc20e7fed8e3e57d5842a72bc40f954860)]);
        vk.delta = Pairing.G2Point([uint256(0x13a4bfacccf976b80c35f66802bb6a25ce258e69c786ea6d63611a8cc0cc2ca1), uint256(0x2c1383cf6a3e2be5190495656b0d3a3987856807ac4246a01fa72fddc56661e6)], [uint256(0x2333c5930a61e9d04bde7a367869f7c8c151f035ee8ac9e361615ffdd4e8ad8f), uint256(0x266ce905781762f7bcc9430a2640f8385f994d067d6c92d54c2b518ed7bbdc49)]);
        vk.gamma_abc = new Pairing.G1Point[](198);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x2154ff5de58490c8105f156888e0ab404ecb800deb235ddea814ec2299e2b18a), uint256(0x246d3ba6d4552277ef7e49b713a41c14106b8e3a1a96f5a4b683293525ee5755));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x0b27dca1dd7a552cfe766862dae0007f0f181503fda3489370884fa175edf300), uint256(0x13b037e04c1db17f8b5607d8700096644248e7fa53cc4bd254d4b535c0a745bc));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x13cb35de301a064d506d22b21fed31d8b3a86e79a8e69c41c9f04bcd43d9e430), uint256(0x2cfbdcd6f4779e376ab66adcd982bdd96e5064f5e1bf526e0b54740072a0de14));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x17dae5cd3726e06b961448fb6e495ec99933c5b22d7ef5bd168b65d00157d8a1), uint256(0x173c22c390b93a0da0d41270f9818e8cf58f6def6ed08878c5a7ca7e2ddc9210));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x2ca36b55d64ba84ea3c76af99135be46b57106cb1c428c852902ce80b61711de), uint256(0x0ee5bb47cf0507bc9b43075601230026d9f80ce47da1ff4aac2e8b920a5b838b));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x021caee08b4f7cdc23eda6cb5015fa5c8adc22a09db6c6b52a396b35bb68694c), uint256(0x241a3a797208d1fd46616ba9db0d4d06fc088b1f78ea9b1fb062bfa55a12fb83));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x09385f935bc8336f43754a77e0c507f29ecdd5de2e4b12a1de41af6944d1f7a9), uint256(0x00919f823188d1934ae66afb0c8b7c2063b7a693a6a73d9690f6006afb36b3c3));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x3043a014fff053fd06a0bc3b2f3c7c2f3a327156a1d8a3cc800cc9fde45fe657), uint256(0x189a937b6e789fa8934a0c9b6be3d8ac130ee3fe019d75e96534ee805648571a));
        vk.gamma_abc[8] = Pairing.G1Point(uint256(0x2e3a6fa29af6c0007944dcbe127144346979dfc9ecb3200db4e6e0c629ff4fbf), uint256(0x26b59e0b5243849716e67ad15ecc218de342037aaf00b3f60cee0ba1ba534fc1));
        vk.gamma_abc[9] = Pairing.G1Point(uint256(0x016db35299014dfd8df681c47765e8f73a416df9548d2ddf51058ca2e63a8e3b), uint256(0x13d9ba839dcbec1861da2101f68c552572846459827d037fccc75515d81448ea));
        vk.gamma_abc[10] = Pairing.G1Point(uint256(0x2b94defd68996ee427cafc5ba786d117c208d4a4b7bdb28590015949a6951bbe), uint256(0x094bd5cc2304ef83b18b1b44d17b14312dc7d02e4d74313aaf4cc1ff10c950b7));
        vk.gamma_abc[11] = Pairing.G1Point(uint256(0x20dd7bc900b70158781f8920d2d8ba289e1a2c2e8b1cbc297f1cc55d231f3ac8), uint256(0x0a3ddc0f9d7a0543383404081d49b564db80f8314e9bc03f52dd439953731f09));
        vk.gamma_abc[12] = Pairing.G1Point(uint256(0x06cc96edf043e7c84a2730851abf8a551315df8fac4f0ac50c3bf9fe145a06bf), uint256(0x17d7a6a00486fbb0b5b271e652c9cd595c906793ac5eaa4f543b2cb40b8a1eb0));
        vk.gamma_abc[13] = Pairing.G1Point(uint256(0x2fcd01a4546c6608aeb966a3c3bb565f6c839d84c03f015c45bc64e7dae9bb2e), uint256(0x01926d90b59057ac69ed3c9d63bc81e633b02a2176e0b71988a6ed6d5a7ec9b7));
        vk.gamma_abc[14] = Pairing.G1Point(uint256(0x1ec7ec17c3a6f6bde17b6c2a9b1725246f2edb78276a34a27f5337f2a9f6e75f), uint256(0x15511fb6e4a3611bfdcd528eb161f4a16d33527e40e19858787d502435b6615d));
        vk.gamma_abc[15] = Pairing.G1Point(uint256(0x258e9d73c28501b45f1461bef7b5f6757990fc278da1374135ebfe6b3ccc3b94), uint256(0x250fb1e175c6a9f4a32f74bfbf0bc4ce07b91803a754b2e5b30883b768e89366));
        vk.gamma_abc[16] = Pairing.G1Point(uint256(0x298c45c1a11202b4ce5d577d53b9b57452d5e8fdd1c7cc7cc8fc5b869528ae25), uint256(0x2186a513409929ccd2556b1881e4a1659dcbde444dadce07ba779d5960e97f84));
        vk.gamma_abc[17] = Pairing.G1Point(uint256(0x09e90a19883405e2ba8df04bdeedf4ca9083e71a2b1e075eb5b72e9e534ba458), uint256(0x1c7d81ee9d0fd60ceb0aadb40373d8f692ba154871fa22301dfabd36744543ee));
        vk.gamma_abc[18] = Pairing.G1Point(uint256(0x019b77ad0c8aded2c75850f68624ca76b70e93050140241b764f02fc145f05ae), uint256(0x10d9b82129a16148cb436cb75e394003c6efdd0a518ccd0a838a87b0c52d232f));
        vk.gamma_abc[19] = Pairing.G1Point(uint256(0x16ee1dced4d53cfe64fedb4ef7317d8bd047b7762a2d5a6e67653e4733b90bb1), uint256(0x02689e648126c450932207a980fae00ebcc4803223bcc2aec7001cd75cfb35b4));
        vk.gamma_abc[20] = Pairing.G1Point(uint256(0x0501a75e1275f8ffcc0abd8b776e7c396c70dac05e8da4ee1fb176f985db52a3), uint256(0x07ad8e65fa5bf05bd911c54e9c407a7e7d68bec0c763c234720c97c399fa2914));
        vk.gamma_abc[21] = Pairing.G1Point(uint256(0x2bb6ac927e152e40c9866dfe14af65814e81cfd17d050b6dce7b39729ea5761e), uint256(0x256292470695843898cd3743fbeca71e9815a65910d6d51e5b30e189c00a5bd2));
        vk.gamma_abc[22] = Pairing.G1Point(uint256(0x1ca8dbeffa4e8d4315e717b30a092f6c4aaf1d8d3278a2885e1b48dfedd7e976), uint256(0x07047ec38a00141d4d7c60b56b44b87d28dc698ce14594e7faa6940f26cafa19));
        vk.gamma_abc[23] = Pairing.G1Point(uint256(0x0d75d07cca5481b06d6da11bddf410a74420e319716293670107c55a5b3da2e1), uint256(0x266fc5af96f6800fa387a55dc949a49ed212c348be26b86704be7b54e8c5b8bf));
        vk.gamma_abc[24] = Pairing.G1Point(uint256(0x0c6683f24f601812e1e857c8f46aa01d9ad5bf6cea1870c2b9236934a1f09318), uint256(0x1fe3cc448f4a422e8f8589a764b95d1f629ed0b8adffd3f25e1fd7e090521b21));
        vk.gamma_abc[25] = Pairing.G1Point(uint256(0x2ab6224902a15f3a0582423484c52838483c48c7de8a3e24e2ad6b917861b2db), uint256(0x2bb67bc8e00d1a186a4f631e7c47d4568296c17389ea4c26b5e61294fe4187ce));
        vk.gamma_abc[26] = Pairing.G1Point(uint256(0x206317610de55b266687c18aaa6d42276d25ae9e1714263d2971da6eb2198a43), uint256(0x01eabeb5f3aaeafbc202c7f2b31097d287a83b0c93f64d2de20134a04fc934db));
        vk.gamma_abc[27] = Pairing.G1Point(uint256(0x1b37d756cc002f8a2f9d5b776c14cb9cc7db550168a8ae5cc0ac483a2b3566e8), uint256(0x156881b0b9b450ac9b6066598f31d10804af138a60f56a9669d9dfc2e0ae3a27));
        vk.gamma_abc[28] = Pairing.G1Point(uint256(0x24f4ea0df7051910c862d6de7d3a118d2e41bc0409359c34062c58f2cb7d9174), uint256(0x04db7852f4c918ec0c761f4cc266e1de3bf7fdf2e74cd218cb926b9382407d48));
        vk.gamma_abc[29] = Pairing.G1Point(uint256(0x1e409ab3bdc3422c74c3a29887d995a71e33f8407533ff619e2f245994197358), uint256(0x18d8dc53eeea0973f41adb4a6f2e6235d2a430e3509163e6d961ef1573cb7488));
        vk.gamma_abc[30] = Pairing.G1Point(uint256(0x16da38dc451a19e3deb2a9129cc012f7d21b996b9039194cb8f1c35d08245c76), uint256(0x131d4f821626b71f054df6556d7f1ff0cc461967b156c7f0dd91634eaa822392));
        vk.gamma_abc[31] = Pairing.G1Point(uint256(0x1cad7f4338a9d9198db9278c7bf7efe5139c2e800f9d6b78ae0a237b3885fbb9), uint256(0x1baff4312d68ecd1d95be708f151b74171c33cc52e5c1575a25935b24f945a5c));
        vk.gamma_abc[32] = Pairing.G1Point(uint256(0x0a54f0dbdadb166f66121c35600dc2e53c2e675d908523726ca39ed94165bcb0), uint256(0x20178e5cf0f5fd798dd270e48b1bf81d930bc1caca4267b55d2ad8afc760d379));
        vk.gamma_abc[33] = Pairing.G1Point(uint256(0x1b36d20dd351273806d0d5e8b6e160ab40213b1a49ba63d6413ba5d1a20f3a84), uint256(0x3042386309d943be34925e37decc1cf182bd28ba8a4a4de720d088512307d424));
        vk.gamma_abc[34] = Pairing.G1Point(uint256(0x085720dadbbed7d341815dc730b90a66ac3a685e6be6a62df29cbaa824c4520c), uint256(0x038e39365c32362bc482b24f42c41887eeb07c4d8909537df1a4bcd676ad5f30));
        vk.gamma_abc[35] = Pairing.G1Point(uint256(0x1588cf2d9cca46c80ffb153fe52dbe415b07a3e05f1df6953e1ab4edd7edd026), uint256(0x0d3aaa0ef5d29bb5d1d4babd03ea23f4ff0740cc5112293888bda2a3268007cf));
        vk.gamma_abc[36] = Pairing.G1Point(uint256(0x202ef1c11bd0d14fe53ed4600b49f161ef091f84ae478607f8c49e733de4a6c7), uint256(0x09bae99409cfb103440685de2f1766275ce8b39bb4c4ef553795f855f59d99da));
        vk.gamma_abc[37] = Pairing.G1Point(uint256(0x15a7561099a57fa64d5897148c41ec4f7a690fe6e8bfc10d596a1aaab7d19d3c), uint256(0x1dce5b86da51960dfb93ad2c4b53194e37f463f98addeae0b82938ff408530ff));
        vk.gamma_abc[38] = Pairing.G1Point(uint256(0x0247f28539768055848c5f72275b846a173fcddb057ea5d38641ed1b67de57d5), uint256(0x0a60d92e050227bec956ff26d622275a77869f6028e523973342a89b46c22dcd));
        vk.gamma_abc[39] = Pairing.G1Point(uint256(0x2b54e99d126b2dbf5a6bc06e564d000b0ec1bdb2001679fbb0e88b6334ee9cbe), uint256(0x2392bc924eb816858b8f50f897eefb2f8a10442c66dd3a65deba60700ef80429));
        vk.gamma_abc[40] = Pairing.G1Point(uint256(0x28b1037390864ab0dd372c5cb191cfe4397d2e88cf2aa8791b97e5c6f9a48f10), uint256(0x01c7c2b986000078b6e0022be0cbba20ee64ea01ed182fa5b6f2d3919eff4884));
        vk.gamma_abc[41] = Pairing.G1Point(uint256(0x0c51e926996615f3ffac84acce2529adf41c1a1de5fbd348aef0953f528ceb41), uint256(0x24e4aed6c3be42c1c5fb37f0d18f7bd328a642b074eefeca67eef49097bd5e94));
        vk.gamma_abc[42] = Pairing.G1Point(uint256(0x03857d5c800329762c1e938ecd83aed55f7271adcfa2420abce3551dd0bd3bda), uint256(0x25f169a08ec24c06bf153e378a7c3e3577a76e3a5288b71fa1c539fecbee328d));
        vk.gamma_abc[43] = Pairing.G1Point(uint256(0x14fee92a91140a22756a2ccf2b8ccf424d63ad12b31aab2f21650da3f0530fd9), uint256(0x1283a4e79acc636a9da0c1f87930e1a2e9a562931c1bf129ff8288e7c261a616));
        vk.gamma_abc[44] = Pairing.G1Point(uint256(0x17577040550ab030a92d5bf12d976c57aabe63457dccbd4634919185f5480081), uint256(0x141f27052ebf3468c7ba75973fe20455f224e806fcb1dcfc0ac622f5ed73d110));
        vk.gamma_abc[45] = Pairing.G1Point(uint256(0x2e3846b57cb4ee8f35db806483083c35be35bcf03ee43ad0a1cc777579068840), uint256(0x2c5bc5e47291290da27d03db73db917cb9c8a54ce547a98d1ae245b590ba074e));
        vk.gamma_abc[46] = Pairing.G1Point(uint256(0x10b832193da5c3a5ee3a49f92ea3000e1bdca05ab9a19aed6cfb62fe85f7399e), uint256(0x28e629028e1295e9e7f4c281164290569feb6398ade590308bb5d8811f8ee8ec));
        vk.gamma_abc[47] = Pairing.G1Point(uint256(0x110a76b2b437f2466656303d6ac1ffb90533e3c9870646c1c912fc83fa757dec), uint256(0x14c75f6a2ba15ef0a77ac1a2663ce40acc4a383d88637c78820c31c4a8572400));
        vk.gamma_abc[48] = Pairing.G1Point(uint256(0x0b448c8da289690e36a0fcebc226bf349ed1b5435894ed5d48d92f5e96ef6dd1), uint256(0x233d12e35c8fd5c0b102d425fefe5afe6ab80a64e37b7a548d254a9c36306723));
        vk.gamma_abc[49] = Pairing.G1Point(uint256(0x10a91646df9c49ad897a62886eb6e877895f2baa421215808e44ff8b9b0ae405), uint256(0x0cb540299ba4de178719e0abd4e384027a8d5049b2aeeba9f563793186f07206));
        vk.gamma_abc[50] = Pairing.G1Point(uint256(0x10cd2b78b00e1bb3d614355ea8ea478e8c177ba17007bfeb05a6237351fe68c8), uint256(0x1c4611cc5e3046970a25322ec5a4d74a9e13fb87ed6d808f4ce4fd4968335f11));
        vk.gamma_abc[51] = Pairing.G1Point(uint256(0x28e5a79166b9f4596c524b9f8a75e8e2d3c281732eaed97e385a9a62b270f31f), uint256(0x070cc50cfdde877dcdcb70968b7e05954ef83291fd21c4bcbac70be91cb7bdce));
        vk.gamma_abc[52] = Pairing.G1Point(uint256(0x272dc56cacbf8adaed132060086d3b8e5c4f80c668f3a04c4c7fa72f6f5e7c0a), uint256(0x08ddfc736e1c7aab1e0fb714018fd12abb6b414e0f2ae59a9bd18f75738e3d76));
        vk.gamma_abc[53] = Pairing.G1Point(uint256(0x0b4ea0cc034cf265c86eb57e49dc4ba0aaf5e5865d65a35ff498158ed3ad43bc), uint256(0x0826dee5606ffe0e0413f5727746f2f0c16a93627e93663d27822798c61f4b5e));
        vk.gamma_abc[54] = Pairing.G1Point(uint256(0x0a3e1fd325dcbe1f50698f63bdf8e8f4fda9065a2aba2ff5ea2e0d7f2d42bdac), uint256(0x15e323a85e1ef9f445a34c27e4a5191f4b8c0d5cb162699b59bd228daa890988));
        vk.gamma_abc[55] = Pairing.G1Point(uint256(0x1e77be507d6d1d752e862028c75551bac98592c9ee11e6032cf55db4cc06fd0d), uint256(0x0bc19950cdb32c0cbe889db7a8eb9aca441786aca3e0baa6f45be1888229503a));
        vk.gamma_abc[56] = Pairing.G1Point(uint256(0x232cbba794cad039f5fc0be192251042bf4acb61bb5738aa8c843d9407143529), uint256(0x2c5473f5040d84ed8eb38907c6645d7a6bc2f279baec3385f9f192cea143a8ff));
        vk.gamma_abc[57] = Pairing.G1Point(uint256(0x2df7aa3df9467081426f02ec36b55d732cdb394cd144705fa9904f061fc86023), uint256(0x2e47160d5328189eb64329c8addc64b5f06cde501fe74ddd4f41556d5ddb18cd));
        vk.gamma_abc[58] = Pairing.G1Point(uint256(0x0a84823937cc07c1beac96438e8420f110877d37f1966528f6e0dcf0d4c065a4), uint256(0x1ec382a9917ada1ac44872a84d1544355320a49a05d295fed3dd413c09f0e1d6));
        vk.gamma_abc[59] = Pairing.G1Point(uint256(0x03cfc5e5f5e638c18fc8800abf316951667574ee2dee3f66eff0f98c325d41d7), uint256(0x116734b41de204650b2b60dc9ae6016d78c5be0ca9f7a9e8f3b650f508c63fed));
        vk.gamma_abc[60] = Pairing.G1Point(uint256(0x0810b4e4648857e4361fd95da6a62efbc7fcbc9bb24cf0fa968bc99e3b87c915), uint256(0x02e492d49bd3dc42eb1b5475f70365610bf06c26bbceb464422b4a25843ab035));
        vk.gamma_abc[61] = Pairing.G1Point(uint256(0x184cd4370ed5934b16a095d14f158bf74deb2fde432e8fbe28046e23ad3f4724), uint256(0x144f23cc7df7cdfad1eef01777647bfa321fbfebb4ae8fe39d9217f98a95bda4));
        vk.gamma_abc[62] = Pairing.G1Point(uint256(0x2bcb57fbcfe3b4f134ed5b980318148081dc415f1658c48e057aeba259d20dc3), uint256(0x05c5dfa3ff8aec60cf46b9ef2ccb3e14749f3c36fc8b51a812cc63a38b3475a5));
        vk.gamma_abc[63] = Pairing.G1Point(uint256(0x26377cb4a4f4cfe62fc430fc35f8cb1349ee4133357f7854a86f3e877a90aaa3), uint256(0x2c52379b6cd2cc158911ad6085b00dea26ab045a9fe63f3a32b7d5298521e521));
        vk.gamma_abc[64] = Pairing.G1Point(uint256(0x1eb329b42608571223017ed7482b7afa93908ff0e0c7d1f5a732ce98397eee57), uint256(0x2ca53f9b9807dacb84c385de1bc23dbfaefb8e92dc33868ba70de69a6874295e));
        vk.gamma_abc[65] = Pairing.G1Point(uint256(0x231c5d6f29be9624c8c2131e8c8fbb335382d5361ab993a55a6acdab1339f655), uint256(0x1b99987c7d7ec8eb7a5b56111dc1d639b08fa70caa5927641a500906534a6125));
        vk.gamma_abc[66] = Pairing.G1Point(uint256(0x11191a7e2800680f3fb1ea6e22069439f92c8b13877513e955db4b8dedf5c04c), uint256(0x0565763bc055d2dd6cac33e5ac70834d2bc275c8e04f17d41aa60214acba38a1));
        vk.gamma_abc[67] = Pairing.G1Point(uint256(0x03069b2943837195b5b31a62b272c391bc4518eedad5ac0a62dd99c184256e86), uint256(0x19068b03b366cbc4d47061e6284feb80f8ca8e627caabe614adc01309d6e42a0));
        vk.gamma_abc[68] = Pairing.G1Point(uint256(0x01e8333d27e3f001b271d76e80bc31d97eeecbc508e116c3ceb32f41510704ec), uint256(0x2d8dd452fa7eab946f01ebce189e50a08127dae6866d272828259aec205e8f77));
        vk.gamma_abc[69] = Pairing.G1Point(uint256(0x1aa1e6b07a14ac2e4180b3d8e092aa39657749d8a16a13ee83cb625f7d167121), uint256(0x021ae20828341c01fa9119c004e5c61b4935f5446f9a6682729b4f009fece400));
        vk.gamma_abc[70] = Pairing.G1Point(uint256(0x283162587ac64f421ceccd6f811bb0499d303a7934c6b416c314f1b274032085), uint256(0x03b8c977843a22fee96eb912bd3dac2e851e7798c732fd94711f75692e8cb15d));
        vk.gamma_abc[71] = Pairing.G1Point(uint256(0x2d8cc403d86fc7ca09891dc3bff7e9c7d7ce913a78a87207be5d1ddf679aecf5), uint256(0x2435921f21ad1e1f2f3ac005aa527807cd2096da6717b1d846465301a4b27f0d));
        vk.gamma_abc[72] = Pairing.G1Point(uint256(0x22a4abd1c5b1e3656a8b4f85015ad830527203cea2458881ae6486dab24d4db8), uint256(0x21183feb8794adf6c8a10580cb93190409c59c3150c6e6de9e12d5d47a677989));
        vk.gamma_abc[73] = Pairing.G1Point(uint256(0x1f59b4821a3ee2d5906fa7be33a71194f521b82eb45a0e664a0c8b1177ef8e25), uint256(0x0b86d8216459b514f15835886973ebb8900f6e4a36a81f7c81af3e1a94dc6a5c));
        vk.gamma_abc[74] = Pairing.G1Point(uint256(0x188fde06d708238297a0a6af775a0a9bc8cf47450eccef9751b992050be8097f), uint256(0x09f2c703c7e52a4084c23cf7fec85a9773b8067a8c41611bbc19b691a62e1464));
        vk.gamma_abc[75] = Pairing.G1Point(uint256(0x0a2654e49eed4344d4092420043612af272a9d62eadf11a62fef089e77ad1842), uint256(0x1e549e7a06580308a26a8ed7135555e20553e8070d96c2ff6b68f29c6b4d22d2));
        vk.gamma_abc[76] = Pairing.G1Point(uint256(0x16340cf85f055cc17817bc8229eeb351b13066a0c174e85e86cabbf3c0ae1229), uint256(0x02773b964913fc88e3b45659ce0ecbaf0e6f67bd8f3b1cceac6964062c187156));
        vk.gamma_abc[77] = Pairing.G1Point(uint256(0x1b7206b3a8414e56d1b10b4d5f03f9b38b7cb6dc4975da7e883c509b09b6e6ac), uint256(0x1a25e6a4dabc7822075e4c0e1b33f46cc4e74824ad23bc68257be8d1c32d0b2e));
        vk.gamma_abc[78] = Pairing.G1Point(uint256(0x228feee6048e10826f61301b6d148137d44cf3835f775c6baf5acc2534054cc4), uint256(0x24475c47c61087a86cc2c5e4e74b4bdec0d6fc02f354b48cdf675f8d0247032c));
        vk.gamma_abc[79] = Pairing.G1Point(uint256(0x0a70f186f0fed6356a80fc5e2db576c3124d56fc2b07fc39f53f81077fb4b893), uint256(0x0ab0e1262bed43e16a18a94c416181ce7cf4c35e952e37f9830fe2f2ab3b94f1));
        vk.gamma_abc[80] = Pairing.G1Point(uint256(0x13f88128b30b43abdbe6f53f19f0a12fac0bb19cd62bfb0c997c8059ccff6f99), uint256(0x2194094336cd2ea53dbafd4e9ff2b371b3518ccc2914fa3fa43bce31b1299276));
        vk.gamma_abc[81] = Pairing.G1Point(uint256(0x227161786ec801a9c4d26bb917cbdae59cdcaa124744894a33c9269e82fe08de), uint256(0x21c0a48685d35db5cbdf615a7ec111bfaaad99d5aaa983a553c27b6412e657c9));
        vk.gamma_abc[82] = Pairing.G1Point(uint256(0x0ba0e6f871c7f291510e4c31f4bf25008a5a8a485cfa1ac8bf1e84d636cdbd0d), uint256(0x194cd9c6c41c9df4e6d5b1a4f0836e372fa40d805db7963579380d6d9aa9b41d));
        vk.gamma_abc[83] = Pairing.G1Point(uint256(0x0e5e9e0726b7b2a7ee766fcc6400c0760896399217f50695cc6211d9e2c5953c), uint256(0x2e7069415ddbd76aa6012302e27685eb37ee3be72e775c88ff3cd0252bbaa96c));
        vk.gamma_abc[84] = Pairing.G1Point(uint256(0x237cda3cd8dfaf9f33d7008f5529e04f6240842259e04972add2f17a7c6d0267), uint256(0x199ce20b5e0e08240e8e08cf29e4be34f4ce96b0714588a21ce2abe3121e651e));
        vk.gamma_abc[85] = Pairing.G1Point(uint256(0x0ccaf3b9c17304cdf21dca1275f785ada3d1a2046f737fe7b9675cdfc5f6f606), uint256(0x201835c41ede086263bdba4bb96a4e87f4156020852e17213345bee875bc8033));
        vk.gamma_abc[86] = Pairing.G1Point(uint256(0x07eb379f2bb0bd5ad2e5d9b38a8796f54c937f0272f52acf137cfec2d948325a), uint256(0x104621da230636e3b7f42909d58a1a974d6a3541c7a406804da9195adaeaf15e));
        vk.gamma_abc[87] = Pairing.G1Point(uint256(0x2e23cf541d7bafda9bd2d9c377c7cdccc942f07149bd913aaa9b2d8332bc9e7f), uint256(0x1ee44f266d463fbeddb4f4cc885a861d5e25090db77683d55212de903305f139));
        vk.gamma_abc[88] = Pairing.G1Point(uint256(0x2a5c900265747d54cf72eae0b52b30d346ea289aade8b29fc67074a144391da1), uint256(0x14871d3a42b073a6d98cc47e9260c0b918f646f43507ec2527849714df7cc63e));
        vk.gamma_abc[89] = Pairing.G1Point(uint256(0x076995ae0185b5d3f651619d5ee995117c73141938d3928b772a18229af7bdf6), uint256(0x0e6202d1dbe976312584f26e5d2302f427592178fd917822dc0043765c5470dd));
        vk.gamma_abc[90] = Pairing.G1Point(uint256(0x1c0b3c75b56a3945f13451f8e6ee577568922834e90b0c4d9ba750aae20738ed), uint256(0x15a7b79ab6f6b12b0bf1c65014c5fae95875e10a4a0a6b64c860c8e32a071bcd));
        vk.gamma_abc[91] = Pairing.G1Point(uint256(0x01a8cabed8a6da28a7d1111cc0ae6c7bc43774d6c8df90ae8328d5358fae8617), uint256(0x17f6671f6875413aa7804fc3df5459adb045e737adbf7df2546c3da6a668fe76));
        vk.gamma_abc[92] = Pairing.G1Point(uint256(0x0e48a70c070068e34263205f196adc57d4d10ef4b3f19300563b4a1622fa14da), uint256(0x25e80141d8f86571ed748e45e37d2d7626cd2ca02658a4abf455f5f2e81c7f92));
        vk.gamma_abc[93] = Pairing.G1Point(uint256(0x1b860db6e825d49fad28727c3757b9cc580f3c4ab6822e4fd9c9d29e5da840a5), uint256(0x1bc0d7d0a11efc976b58607e558b83078942634aeb5fe6e5cb4cbd1d83c35664));
        vk.gamma_abc[94] = Pairing.G1Point(uint256(0x247151f55ed1c0ca122327c94cda541f26c2c058522671a8af28da4f15756517), uint256(0x00e2f1ecd70e4753858367aaa8a7972e9df79fe30490cb220200ab54f8c43022));
        vk.gamma_abc[95] = Pairing.G1Point(uint256(0x258fec2ba44043537adc12e56cd1ff523daa2fb684f84fb07c691024f7a8a6dc), uint256(0x2c461b775be4cd6ef442b40227cd7a1770011fb259885d3e911f027570bdfbc8));
        vk.gamma_abc[96] = Pairing.G1Point(uint256(0x30058a55e5a6a3ebe54d294d60a158026025eec55b170c5a505708c0435dab88), uint256(0x1b80dce4eb3843f5b35c6f2bd08d5dcf370479e7113f26df61afdf202f38fc74));
        vk.gamma_abc[97] = Pairing.G1Point(uint256(0x0228a7ded0ea50cb7f48914586cf6f4a50c75be6038150a5c8819344fa050403), uint256(0x176ad153b3a89199b6b55293751866b96ff7e2d7904f1f1b181ea9d7c44c37de));
        vk.gamma_abc[98] = Pairing.G1Point(uint256(0x2ee53da28a328e2ba10ce2023e1453b56e010eed92d06d0cce97afa7323f70a5), uint256(0x1e98a3e699269610fbc84a0c551e9cf5ba12f7c2fded0e6404c4b1e8ad0279fc));
        vk.gamma_abc[99] = Pairing.G1Point(uint256(0x0217da96f47a83c3425ab22d9597be0f93ccb42f73e9765be21c76b835e39360), uint256(0x0752e3a1e644f44b6a8b95571bea1d93a8b046667d047b3e0a6eaad0613d7534));
        vk.gamma_abc[100] = Pairing.G1Point(uint256(0x236ac5575356f7f35eff5761eb3fa8d21e5c41171396bef9b5a20e17b6b11367), uint256(0x2d017fb26ad4fb7c6877892e21e2d493f96bdc941371b4cddb0097032db8c5f6));
        vk.gamma_abc[101] = Pairing.G1Point(uint256(0x1d02d437d6bbaccfa8d82a9afffa1ec189977be60060bfd31058cb2e8258282e), uint256(0x142894db656ebedc5276c0cdf5c58da9b9a4795c9c4cbec5341691626bd1a8d6));
        vk.gamma_abc[102] = Pairing.G1Point(uint256(0x0936c76c983c161b4cb0cde7cb9355da1da182ef168973c795eb2214c8c29c36), uint256(0x068f20f63cc74ecd6d17b3202d05f6e1c58e7730e8a91776fdce218b1c0d1ce7));
        vk.gamma_abc[103] = Pairing.G1Point(uint256(0x1efc73ec5477ced267c414bd3c3722bad86ed4d37206082ca933886813fd446c), uint256(0x1899be7025338178863227b8fe27f5dd3de092adbccf9eaa928b2d35a5e21aac));
        vk.gamma_abc[104] = Pairing.G1Point(uint256(0x26f16bd82d1962a21f63b84341e621b80515fe6605d170271276fed54fa520b5), uint256(0x1e5f83e62774e726cd241439e001da28c2865c19589fed044cc1e768adbc19c4));
        vk.gamma_abc[105] = Pairing.G1Point(uint256(0x0a8f5b38dd5a4c2bbadebfa5b4a47f9e4073e8343c8148d822ee98e77817aa1f), uint256(0x19c6c03b34e376543950a8bd1ac82269080c417cb5fe7bae3ef7d13dac8b7828));
        vk.gamma_abc[106] = Pairing.G1Point(uint256(0x074be7ea8676e6d1d7779a9494da755178b5e0b646a6ed13b1b62e2cec721b99), uint256(0x03697659fff98c0cbb84a684503768282bcda07867d7ac240b134967b04b4bac));
        vk.gamma_abc[107] = Pairing.G1Point(uint256(0x06c59e33c18957235ce9a7e4594c94da77d5af08b81894c73ca96bafa2a8f232), uint256(0x248c2907c5a83c63ab12ac074959f6a707e0c35dee1d88e156872a4f41080042));
        vk.gamma_abc[108] = Pairing.G1Point(uint256(0x2f054adac9a9b7f3de412e15609051e20385288dfa922dc614db62bb207af073), uint256(0x12eebc2314ce14da93ee6782e0eb32cb80d170792056f5a00a381e8e2b093426));
        vk.gamma_abc[109] = Pairing.G1Point(uint256(0x12f8ae82528f3a1b6db387e2614a2d2b317918dcd6846329421eaaea6a5922fd), uint256(0x249ece8e1b9cf8d10e295ebd970ce608cbfa91275755bcbe58a0ab57e46c1616));
        vk.gamma_abc[110] = Pairing.G1Point(uint256(0x0932f05de5a8f3d05bd1514831c3782bf96efd31f14c566408d9dfd1143f2bca), uint256(0x2d4b6fe350531e97d1262e572a1a1d529e7f085ae8187b1f1db397020ab03df4));
        vk.gamma_abc[111] = Pairing.G1Point(uint256(0x0fcddbc00bac362f8b06fae4af5ac7a954f5d8d227b459d1d3ac41f85e6836cc), uint256(0x2c0409f217a9bdd7668684e923520773be4e793dc7cabb68909fab5d9fbdcfad));
        vk.gamma_abc[112] = Pairing.G1Point(uint256(0x2769b69c8dd4c554caae3ea712535c24a8a2d511ec9b9cefdefc72faea59d02b), uint256(0x2d6f0dedf5fab7c87ab8fbb541268944c58c2b8a18e35ca7115b2f3b821e42eb));
        vk.gamma_abc[113] = Pairing.G1Point(uint256(0x15f691e6bbd8f28c21acb682ea230d214b7228647db7577f9f0fd51b8d6989d3), uint256(0x198a756db0a607fc9a55799b35e92fc075acb173cde9c0704429f5e2af3aafcb));
        vk.gamma_abc[114] = Pairing.G1Point(uint256(0x0af4ff21b52651c5fa2a32b90dcd91ba96997dec7d4d9ce135c421256c24cbaa), uint256(0x2e9e83bd0daf35a082dfd9379db8c016f033dbb271366d63d6801feaa8ba80a0));
        vk.gamma_abc[115] = Pairing.G1Point(uint256(0x0a276adde696fe1d28ef3ec43830f7b19876a5684b45a343cfb36947dca1e8c9), uint256(0x0341cfa997db92ee71fb08ba3ae604167f95d2d4fa17b4d70841ee068d25ec8f));
        vk.gamma_abc[116] = Pairing.G1Point(uint256(0x2f5a0680998f1d21566942a3af34aa5759e194de348e150ee968affc652d4857), uint256(0x1eae179b3ef1d6c6bcca51286511815c6dba33120884ad83ce73d118091055ab));
        vk.gamma_abc[117] = Pairing.G1Point(uint256(0x0745845a749bfee98e23987f8f5b95a057d33857e6d163ba821b55850c1dbf19), uint256(0x266e02a82c29eb3313d0befcb6ddf6e753869d33bd8fd4f393fe0578a65ddf3c));
        vk.gamma_abc[118] = Pairing.G1Point(uint256(0x18dca945658acd148791ee548094369358caa9590730b8b5757fd1d0e2273382), uint256(0x1d734cfb3c92661ef0be8d75f75006e7b9d2c6b6d978b8bc401d134313094eba));
        vk.gamma_abc[119] = Pairing.G1Point(uint256(0x25c795093a903106bb727ec520375257bcedfb3b67249c99546813fcc6838aa0), uint256(0x0941e4223c3536b9ac8a50268f5524ab7d29ae2817f262c993db8c1547dcd61b));
        vk.gamma_abc[120] = Pairing.G1Point(uint256(0x062713bcd4674895fc6914dfbefb1ede157310c73d4f2a270609e4726c594c86), uint256(0x272df7912a26525de516658b9395e8b08078f900db19e9f23d4a45d2b290a672));
        vk.gamma_abc[121] = Pairing.G1Point(uint256(0x128ad826a578dea20de9a4de32a8b7dd76b3c832e5ba09e631b1261e548fec2a), uint256(0x14f43311ddde6a168cc28b1fe4168e4b5127f4740ab28f4735036efdcabb5b4c));
        vk.gamma_abc[122] = Pairing.G1Point(uint256(0x1b71d001e37c318fd58362f4d96eaf6a95f41c27b7c2db4f93a01f59b602fb3c), uint256(0x10a82fefce674363a7c60bd43078308300c604c96423b74641815dac3dc9b161));
        vk.gamma_abc[123] = Pairing.G1Point(uint256(0x01a12d4c53579ad43dcf143e64ee6dcf32f3e1369be148a8b7025cc5175167fa), uint256(0x20056dc4ea48bfd52d926dc26e924327f8c1a94f6cd000feb2c3d5c1f9a93dba));
        vk.gamma_abc[124] = Pairing.G1Point(uint256(0x1c995e37c7b3eaae87a319a2273e0e1fe9c10e2b5202bc5804fc23cfe74a5201), uint256(0x252f6533161694b81102ff853227c979e1e81d7c6fb0fa46e00d9efe6f369e69));
        vk.gamma_abc[125] = Pairing.G1Point(uint256(0x2365a6941cb8e8fb00b898a485bc608c0b2d48af876724cbace871a698014fd5), uint256(0x18e347ab1477f2f76a250f8f41e0350b58e1ddfa900aeb5e7a90e3682d1f3ec9));
        vk.gamma_abc[126] = Pairing.G1Point(uint256(0x0dc200da1e10213f0b1bd95a88bbf045552d9181ffaf908a502b7c1d5411a931), uint256(0x1af492030416e0dbc7644d0f528eca1f6366245c3fd55cf1e3f081326a01750e));
        vk.gamma_abc[127] = Pairing.G1Point(uint256(0x28271d5a7cbd4e1cc651fc7cb28b0dcfee7b1298ee6793d59f2d84b5bef8c60c), uint256(0x0e13978c47846fcc0d656229083f52202bedbc1a1ba156d6a4c20e8933ccd472));
        vk.gamma_abc[128] = Pairing.G1Point(uint256(0x2d79c723db2bfd441cd4abd29fa090b4ebcdb0752b5f2e7665fb6ab59b8126da), uint256(0x03f4c353c81f8c9ce53647d021652def96cfce886e1eb8718182c3c14ce0a59f));
        vk.gamma_abc[129] = Pairing.G1Point(uint256(0x1a7e69c243b69f32a3ccea472af9fd5b3b16d81ad803c67987717be646119794), uint256(0x10dabbd9ce8adcb66c86958bc7c7a790624d4a83094225dd5857a4456cfce649));
        vk.gamma_abc[130] = Pairing.G1Point(uint256(0x2c9e8c867d6bf152c94cea7ff9627765bd4dc3b0f78edf22661522145711b13e), uint256(0x12e4dac64797ede5b92ccb77c2b4d4725a2be310c36035c59a35926bb060261c));
        vk.gamma_abc[131] = Pairing.G1Point(uint256(0x1ff224694b1bba51e3d34194e9e67146ad7db784d29d9d5d4217f1db53423e4e), uint256(0x185aae025c61a4142307c4ef00c4c5586b1d6732c4a7017a02b6c463b2f5017b));
        vk.gamma_abc[132] = Pairing.G1Point(uint256(0x2ac2490cafdfd2db7b6ea77db53b3db8099752e01ae15617d1c91f709ff71619), uint256(0x18782f00d67adf497e5572071a9423dcdb767455599b0801e04982719f1cc1e1));
        vk.gamma_abc[133] = Pairing.G1Point(uint256(0x0629aabcd74eddd485b71b6c6aa826532956a986387e26e9974f2817ffc4a7d4), uint256(0x2b4ec565e5c8b25d0702add1ad7a8980a8c4438fc28ec37d136e11798f4edae7));
        vk.gamma_abc[134] = Pairing.G1Point(uint256(0x303fda48ca71014618f016ee833a083d57cce262eb0d928a3db1b57256ab7006), uint256(0x142201144b62627eac26993302dad82ca2d33aba8958011eb2362798bffdae5b));
        vk.gamma_abc[135] = Pairing.G1Point(uint256(0x01e007e2863192e0b6577739d8361bef37213106b27f0d86b8d5e5957eedaac6), uint256(0x2e04667bfa95c71a152fd58ba807b8340513e11e2cfe6e57da8f1bb2ea5b2ff7));
        vk.gamma_abc[136] = Pairing.G1Point(uint256(0x1e304319b7ce65779b9a98b5135caad8430ca3051c5397ba82cbecf75907a61d), uint256(0x1b9848e287be2c985f9baa1ea7a68acfd98d84094ae55ac546712517c897ee31));
        vk.gamma_abc[137] = Pairing.G1Point(uint256(0x06fb46a9a25c1a3eec8c338c7c35749a2d39bfe75f2f79cf464f0831579d6cff), uint256(0x27998af8cc2feaacc93a6ae555540d9d63522c8dc92b3bb5f034bfb0de9ea098));
        vk.gamma_abc[138] = Pairing.G1Point(uint256(0x0b73758d52f61349da574451a7a917259be445d97a17d85f0aa1406689961312), uint256(0x1730270814bfeec1b7fb929472e83d582ab91ce621c535e578049f02e2dc941e));
        vk.gamma_abc[139] = Pairing.G1Point(uint256(0x0fe1632f6a7fb2ed28c2f8c4c57d9e811de8703598216cd8a86d5646d9b7a0b9), uint256(0x04492fbaf2c979d1a69d5f06b4de204677635de84b3de0216430326322f72552));
        vk.gamma_abc[140] = Pairing.G1Point(uint256(0x2f5742757194bf6c276fc27a05dc25780578ba591fe59d3777636a81a6c4ffb7), uint256(0x199e9b2c6c08c3fa0b5ac75bee036dfe7eb8e01614ce1a6b41ca4c81553e1492));
        vk.gamma_abc[141] = Pairing.G1Point(uint256(0x270951194a43a01c77faaa7a2a7b1d26558c1310829328ed994ef06c3ad16aee), uint256(0x10f8c278b305a1b20ab08de96b2fb53379028a3ac8769540e62df8b618a65cfb));
        vk.gamma_abc[142] = Pairing.G1Point(uint256(0x1780749c2895d5c8cdb7c267f2cb3f8f91e327c546765fefb24b592c40e54642), uint256(0x1eabc12162be7107379759c586adc46b9aaf794e43cbc0fc0fe96510a4b1b3cd));
        vk.gamma_abc[143] = Pairing.G1Point(uint256(0x2774b8b804004e0e79ddc9195214a189f92fe7e2ff892ebfcfe4901075a8437e), uint256(0x1f5c45cff6fc8cfecf933f723be4d83aeb5995cd25db330e11269a0e12e1d5f0));
        vk.gamma_abc[144] = Pairing.G1Point(uint256(0x181e96f1b9f6713e314c61be779defc8af94354b2a78f201787cb46958a6f64a), uint256(0x29c7c9c601625a1698a4dd8b02c581744389aab24a0491c7c5440baf1b4d1a5f));
        vk.gamma_abc[145] = Pairing.G1Point(uint256(0x1a93fd2d29ff49536fd3440aa80004f80435036de6b710b932991be2459e0192), uint256(0x082067edc9739f25a1a3fc386caf7d5c2ef312e7b820a67887f635b195655759));
        vk.gamma_abc[146] = Pairing.G1Point(uint256(0x0026d5d63fe27175c91a740e3f5eaf22295f4edd2710c243a29b2595f67a4085), uint256(0x024adb14653e2e91f2ecc4de6882b4f9fdc234a0c8b0881199884047ce2432ae));
        vk.gamma_abc[147] = Pairing.G1Point(uint256(0x29b88c8929b93d0b0dfd89b1037b1b4444b0731e1b2e1bb1e7f69a1bd6e39f71), uint256(0x134f60af120bc9480d20a84346d88e1ee546d63666259623a8b73e2e74e2fb60));
        vk.gamma_abc[148] = Pairing.G1Point(uint256(0x0a54cac0d1edd2d7fb416454af9875913dae6a8dc9d46cfd4f774920fc0713bf), uint256(0x261bbdf67f6a83aa245bb9a91fbde360a0687aae22a7714a175b7bbb506696c4));
        vk.gamma_abc[149] = Pairing.G1Point(uint256(0x2e5f784ce54f07ccad6f4997a54cd83321400e87bdfa0d84255f846bc3f02e43), uint256(0x0c8ecd578a51c7d71f6efd3513bbcfb2ebbbb06805979509fde06436479a36c5));
        vk.gamma_abc[150] = Pairing.G1Point(uint256(0x25275398e90d93f02aa71fee46ca168781fb74422b082ca5c9eba82030ebbac0), uint256(0x08878579481a5f4e76a0c682c583ecfe3ff5a444ef8fee58c3944c5dc6d45df5));
        vk.gamma_abc[151] = Pairing.G1Point(uint256(0x0bc447b4108a3efe5015de05b57a90d41769e555ca9d992ed3d470fed46eec83), uint256(0x0ce30d6fbb01676790d07fd5c449bdf4bc465bac8f272c659ebf68078da8d7b6));
        vk.gamma_abc[152] = Pairing.G1Point(uint256(0x171f0033a290a7888e9a44b60cc5fe65efa0995b62a823f777eb89e205d52d12), uint256(0x24d0060dcd6c8e42738f5cab55cadc6a6dd322524b7f0ba4d9070b0688c74466));
        vk.gamma_abc[153] = Pairing.G1Point(uint256(0x0c78c4496815a72da711d62d3179de09bcbc63bc58a6628bf5f66a9f5bee5c96), uint256(0x11f8a4d67ad650463fc140c421afa61ea0b5c0f6af7cdb39446068b910a755a5));
        vk.gamma_abc[154] = Pairing.G1Point(uint256(0x125f6218d1ee827da33e6752a3f39ee76d1c7e66b48a6e8dfdbe3b5842402ac4), uint256(0x123625cbe283749546fb57cbb22bbfa64d005418890957b5d0636ed213334cf3));
        vk.gamma_abc[155] = Pairing.G1Point(uint256(0x02417d2a2842f637c024fbc475b41fb64e3c1dbf19cc55f15ba7c525ef79ef82), uint256(0x2a667aa24cbf621167b31add434c4675b2a8634a449a7210c08d778d3bd1baac));
        vk.gamma_abc[156] = Pairing.G1Point(uint256(0x1eb667b5dd99c72ee1032ecb38d4d340ee4e66b3ede7f8ded64746b0d492f96f), uint256(0x2ec357bc81d21b1f1e99e3d09c9c4a60d831ac50e263769b65ba6f6a6214c04d));
        vk.gamma_abc[157] = Pairing.G1Point(uint256(0x08cfb3f7c50edc9fdda97dab8a6fff1d7d90d842f1c0f1c07c8d9b7d47d3ceae), uint256(0x08023679511db226156e0d237f6060a1c95d68b1c75c899d21e05701a9d46a67));
        vk.gamma_abc[158] = Pairing.G1Point(uint256(0x0011c11d514ce238f68ddf706ccf59a5773b868497d5ca97ab990d99e8f9703e), uint256(0x16ae4bce15e206233fec129dd19e12f46df58f360883c4c77e6c3c2fabcbf0b5));
        vk.gamma_abc[159] = Pairing.G1Point(uint256(0x030f00c2f432a631860b3195c27a80d21f35ed8785d832d95a3b888543f7a2d9), uint256(0x2dafad3fa7a097a73fdecdc63b31c5bb6881bf0ae42d403422c054d670cbda0c));
        vk.gamma_abc[160] = Pairing.G1Point(uint256(0x1293f0a710cfee072c5f194cf52c73e599146f29193c95be61942f76b8078de3), uint256(0x21ef810e0c7111c31267f5e9c9f2f82e14e1cf223fced6cc098714ef590d60f4));
        vk.gamma_abc[161] = Pairing.G1Point(uint256(0x24931a63aaaf7901260c6e3a6b6c7c533e4ff7bb97d29e430678d9e1123c6ac8), uint256(0x04ad8ab1ef55407f6d1efda3eb71e287afe87c9dc8c0ce14ad5e325d7127f1c1));
        vk.gamma_abc[162] = Pairing.G1Point(uint256(0x2ffa37f684b516fbd0205cbafd7a2eb952ac48df055d2be8a892db8015feb798), uint256(0x1402b1206eb1363fd678b26e8e089fce0506b317c2b8032af3df7f13fe357130));
        vk.gamma_abc[163] = Pairing.G1Point(uint256(0x007bc21741bde7b44c4db78c9e6a6cdac4a6c96cd6e105af469e246cdd2c1127), uint256(0x2ec38823a52ae09e47797a3f5a9e7bbe4b20e5b98772e9ced453dd31fa3928b3));
        vk.gamma_abc[164] = Pairing.G1Point(uint256(0x0b9db7a0204c0f8e1ab23d63c536a76b2baef051545d04554b32458e2b6cfad1), uint256(0x1e3148d41419e808488756ac5bdcc8e50e441828e44a30777df8af850eaf45e7));
        vk.gamma_abc[165] = Pairing.G1Point(uint256(0x012ad3aee6f9f4acda17827f6d9d61214b717e20625387861cf44ddcaefac0f7), uint256(0x2ab88d0441a798ca77a35d807ec93cc957d543e593edaaca1c9fe9425bbf63a2));
        vk.gamma_abc[166] = Pairing.G1Point(uint256(0x259be66510947c36a4d2a17b3ae46d9754816059193d1ca048ac60e8b050fe48), uint256(0x017e04daef8921542a0b5c22ae6470e6549592272a88336d34bb2a42b66b3837));
        vk.gamma_abc[167] = Pairing.G1Point(uint256(0x0a0c83603bab0adc111339a7ccbc3877850150bd08aab11a0e47a84886807fdc), uint256(0x10ff2538a8f0497a41f84c80e455d5241a9f686a3431c02ba7d5e3f8c0a31b9b));
        vk.gamma_abc[168] = Pairing.G1Point(uint256(0x2467f6f51b9697b87176dfb163fd74e31d8eb216587cf5b52da863c60c734bbf), uint256(0x259c6933ca6dada81ec097a37deb8bd97be56982520f07ff7b5286961fd70a8e));
        vk.gamma_abc[169] = Pairing.G1Point(uint256(0x29b38e775a58fd7d4f6de6f36458d9785ecad35ed3da8f3aab2c9db82751f2d6), uint256(0x0036807fcc86bcdfb6ef67d63c2f0ebbcfd87d75579ce6d0257200133c677440));
        vk.gamma_abc[170] = Pairing.G1Point(uint256(0x21e99e15291873f15112b6dd758d409348a3960bcc499a3f1a8094d7b14c1cb6), uint256(0x1df28166a3c2f60a1642d42b8157ed0a3d364c7dea37088389ed21276e952013));
        vk.gamma_abc[171] = Pairing.G1Point(uint256(0x16c13b0b9fc302cdcc4d75c1d343c9619623ea804061846f07f06b7efc3c833d), uint256(0x30095dd907331419aac81a5b95cb6b75dd25be877a0b96975dcdc8293de9800d));
        vk.gamma_abc[172] = Pairing.G1Point(uint256(0x16db790a0875665147c91b10b924becea9e885871d445cbaffa889f3136c62ed), uint256(0x17f26ceba917c48fa5a9077aebfea2682e62f6d9e3a8d81d0a6cfedf61ef04dc));
        vk.gamma_abc[173] = Pairing.G1Point(uint256(0x062802fb7c4f642f24e8b2da754147700673845571ae6514211a370fa91a2138), uint256(0x2d2baac3c4f1960e3c57430367259ec298f2e7266d3bba083884e65f880a9bae));
        vk.gamma_abc[174] = Pairing.G1Point(uint256(0x0e4b613507f187c04f4074a55185008979804ce1b82e86554fc1a198e9dd2f00), uint256(0x00f78fa707ec450f9e6589b7d100ba9fd08d444f0e85a4415dc8bbaa1db621e0));
        vk.gamma_abc[175] = Pairing.G1Point(uint256(0x00dc320d6dab850224353152b7ea4051e27a14d710e0b31986b234ecd2952789), uint256(0x03c07d8c29e82fc6b347950c07f39f3ce8b85d597123d31170adf3a41ac5130d));
        vk.gamma_abc[176] = Pairing.G1Point(uint256(0x13e357a3189565312cbd490fd9dcf36dd0982c8e55b398093672b4d4862b0225), uint256(0x1d3980f7d628e37d5a0ca9d401b5a002a3c9b008e5ee876bcb8b562e634705c8));
        vk.gamma_abc[177] = Pairing.G1Point(uint256(0x2fd311ae4caafd0230058ef968c97954f162c96d3f39c9df250b78572173d6cd), uint256(0x21038da21810ce68630002bd8f61b14da4ae3c61918538082777ac3c250b5800));
        vk.gamma_abc[178] = Pairing.G1Point(uint256(0x06d7337044063b9a1d37347ad66eaa7911f1aad6a935175db7ee8722d25b8828), uint256(0x197b63601b3939e9d7d0346b2c822781e40ce6932413f06c031c7c75fde7ac3e));
        vk.gamma_abc[179] = Pairing.G1Point(uint256(0x099f99dad5bf1dcee2820101892edc9dce5f6322500fb5cd3aef0500e742d7e2), uint256(0x21f097a528cb7295d9445683630e42cfe9c124e100420247f2c68b223261d0cf));
        vk.gamma_abc[180] = Pairing.G1Point(uint256(0x1745e4ef086fb1fc6a836b896b7457d241b27cbc7e4d22035704c7ed5b1ea361), uint256(0x0251f22abd55e571cb71b81f3d2cf48f113d3890c5251be621274a8e140ae10a));
        vk.gamma_abc[181] = Pairing.G1Point(uint256(0x2dc90d8084362d5ea7f9d184eddfb58eb7cfdefd950cbe47d7eb4cc150565144), uint256(0x14db4f075e575557a134e9dbeff1d1371b8939a1ad609d305300bf57c0270c38));
        vk.gamma_abc[182] = Pairing.G1Point(uint256(0x20e2309be136497ee4bcedc279ada1ac61498a8a7c1ddfddb720059b72df716d), uint256(0x16e37449f02e1efc9e07baad645d01b5acad844361dbb321d7b05f6d49f6be95));
        vk.gamma_abc[183] = Pairing.G1Point(uint256(0x0bc5e112eaab3b899c79bc231dcc970f2ca29ebbdb40fe765bb90e4ef4cc0020), uint256(0x1ae38d85f81c8b81682efd2bf5ef670b91ffacbb4dea736e7c73f780f545d9d8));
        vk.gamma_abc[184] = Pairing.G1Point(uint256(0x2bdf50ef3c6a534fd51c8613f6fc8c17eec0793cb0d330f1c3bca481e504c3b9), uint256(0x19402d7a2c4027d1c7bfd058ebe3f5a1dcde05137b8a752f841d6c93bca71cb7));
        vk.gamma_abc[185] = Pairing.G1Point(uint256(0x1140c0964380996f628ddb36008a637aa22faf712c3d0b7cf471f781cd83f343), uint256(0x01216e18430cf7039e3d2ceff87769831218f5b89299281095c02d57b7021f00));
        vk.gamma_abc[186] = Pairing.G1Point(uint256(0x22dae14a178963ccd88199fa87dba183991d9b32e036025de2564c0c764efebd), uint256(0x01576cec7c87319cf15d267504bbae7f99df9b4805a5ac00326edd760e74ec7f));
        vk.gamma_abc[187] = Pairing.G1Point(uint256(0x067fc1fa4a40918de30e7a060331f16248cd181f56d6622637e0a50d9e0f0ed8), uint256(0x24922254bb3699db906519abed78ac76560200a39487cd9295cb912fd8439971));
        vk.gamma_abc[188] = Pairing.G1Point(uint256(0x01ef531ae5e8276bc05cf620b4d4e64cf4e76c06419dd68b264fbd7845df6f35), uint256(0x28eaa4b5006966cd592e6f3dd1409d482a561f274f9e315be60600816c0148de));
        vk.gamma_abc[189] = Pairing.G1Point(uint256(0x226ee01a7c805429c0f5ac482c39dd2d00452c208bb5e6f5a72ed4731de121d2), uint256(0x1daf7fa30295f0a653885c58ecaa491574885f779fbde5e9eda7e40478a1bcb0));
        vk.gamma_abc[190] = Pairing.G1Point(uint256(0x0b43442ac2aed1149dce181a336dc7bc6dda573340694d18bdb64da16f828314), uint256(0x103c01d63c89e058951bf7e758174dc73a73b548cc870c59289b7e5bfd541b78));
        vk.gamma_abc[191] = Pairing.G1Point(uint256(0x0a60b38990e2ca343179bb6905b5a652f4592d725eec1a147474c74133b0ee08), uint256(0x1940595bcb25919183d95da3dec71c0d7642da3a9b64bef30bf7ee84b6a4145c));
        vk.gamma_abc[192] = Pairing.G1Point(uint256(0x1aea61e80ecd14b5b4ea455b16db0e942b61061a8ec5a4bcab52ec3bfb115748), uint256(0x0f4d6b542aba2945d1b624288bf4eadcfaddb9cb253ae7837ae55723375cf0e0));
        vk.gamma_abc[193] = Pairing.G1Point(uint256(0x23073f7ec303417c7d6f80a7fc6e55b9ed1a4fde77355e9d96baa81696262184), uint256(0x0374172eb542fa78d1743349720e3de8d0f8ad39a7c22022c0430cc3d6c2b145));
        vk.gamma_abc[194] = Pairing.G1Point(uint256(0x1e1a8261b4fcf2c675ceee9efaf77029fc5e65b781bcbf1d0035fa7873f15010), uint256(0x165152751931b775319072aff64fac78776d7dfd3448d3700771eaa736c22cfb));
        vk.gamma_abc[195] = Pairing.G1Point(uint256(0x253cacc9dd4b66459f5a0e0c65d001f6643226eae8b84f377ae9ae394cf4c549), uint256(0x07f7eda5246033ec1ca056560ede8b04044236d170a3bc920066fd1b2c28395c));
        vk.gamma_abc[196] = Pairing.G1Point(uint256(0x297973bd397057b7ca49eafd42c4987b49417d71bec08f557e39a4a238275ea8), uint256(0x0bc0b5b8cba9ed981baf1c5396bd76593f65cc1a52110bba6e4ba230c26be69e));
        vk.gamma_abc[197] = Pairing.G1Point(uint256(0x2406d855b323c681efd47b3374f1095f67e215e8c9b8497cf68f773a82c25095), uint256(0x23bb76b5e2e1842945e397c933e27ccf4905ea15c9f234b1b3d476eb5d6403e2));
    }
    function verify(uint[] memory input, Proof memory proof) internal returns (uint) {
        uint256 snark_scalar_field = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
        VerifyingKey memory vk = verifyingKey();
        require(input.length + 1 == vk.gamma_abc.length);
        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
        for (uint i = 0; i < input.length; i++) {
            require(input[i] < snark_scalar_field);
            vk_x = Pairing.addition(vk_x, Pairing.scalar_mul(vk.gamma_abc[i + 1], input[i]));
        }
        vk_x = Pairing.addition(vk_x, vk.gamma_abc[0]);
        if(!Pairing.pairingProd4(
             proof.a, proof.b,
             Pairing.negate(vk_x), vk.gamma,
             Pairing.negate(proof.c), vk.delta,
             Pairing.negate(vk.a), vk.b)) return 1;
        return 0;
    }
    event Verified(string s);
    function verifyTx(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[197] memory input
        ) public returns (bool r) {
        Proof memory proof;
        proof.a = Pairing.G1Point(a[0], a[1]);
        proof.b = Pairing.G2Point([b[0][0], b[0][1]], [b[1][0], b[1][1]]);
        proof.c = Pairing.G1Point(c[0], c[1]);
        uint[] memory inputValues = new uint[](input.length);
        for(uint i = 0; i < input.length; i++){
            inputValues[i] = input[i];
        }
        if (verify(inputValues, proof) == 0) {
            emit Verified("Transaction successfully verified.");
            return true;
        } else {
            return false;
        }
    }
}
