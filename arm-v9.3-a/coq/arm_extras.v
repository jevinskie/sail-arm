(******************************************************************************)
(*  BSD 3-clause Clear License                                                *)
(*                                                                            *)
(*  Copyright (c) 2022                                                        *)
(*    Arm Limited (or its affiliates),                                        *)
(*    Thomas Bauereiss,                                                       *)
(*    Brian Campbell,                                                         *)
(*    Alasdair Armstrong,                                                     *)
(*    Alastair Reid,                                                          *)
(*    Peter Sewell                                                            *)
(*                                                                            *)
(*  All rights reserved.                                                      *)
(*                                                                            *)
(*  Redistribution and use in source and binary forms, with or without        *)
(*  modification, are permitted (subject to the limitations in the            *)
(*  disclaimer below) provided that the following conditions are met:         *)
(*                                                                            *)
(*    * Redistributions of source code must retain the above copyright        *)
(*      notice, this list of conditions and the following disclaimer.         *)
(*    * Redistributions in binary form must reproduce the above copyright     *)
(*      notice, this list of conditions and the following disclaimer in the   *)
(*      documentation and/or other materials provided with the distribution.  *)
(*    * Neither the name of ARM Limited nor the names of its contributors     *)
(*      may be used to endorse or promote products derived from this          *)
(*      software without specific prior written permission.                   *)
(*                                                                            *)
(*  NO EXPRESS OR IMPLIED LICENSES TO ANY PARTY'S PATENT RIGHTS ARE GRANTED   *)
(*  BY THIS LICENSE. THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND   *)
(*  CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,    *)
(*  BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND         *)
(*  FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE   *)
(*  COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,      *)
(*  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT  *)
(*  NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF      *)
(*  USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON    *)
(*  ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT   *)
(*  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF  *)
(*  THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.         *)
(******************************************************************************)

Require Import Sail.Base.
Require Import Lia.
Local Open Scope Z.

Definition write_ram {rv e} addrsize size (hexRAM : mword addrsize) (address : mword addrsize) (value : mword (8 * size)) : monad rv unit e :=
  write_mem_ea Write_plain addrsize address size >>
  write_mem Write_plain addrsize address size value >>= fun _ =>
  returnm tt.

Definition read_ram {rv e} addrsize size (hexRAM : mword addrsize) (address : mword addrsize) : monad rv (mword (8 * size)) e :=
  read_mem Read_plain addrsize address size.

(* A version of print_endline in the monad so that it doesn't disappear during
   extraction to OCaml.  A change in the Sail library declaration has to be
   spliced in to use it. *)
Definition print_endline_monadic {rv e} (_:string) : monad rv unit e := returnm tt.