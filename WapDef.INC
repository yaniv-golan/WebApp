/////////////////////////////////////////////////////////////////////////////
//
// Written by Yaniv Golan, ygolan@hyperact.com
// http://www.hyperact.com
// Copyright (C) 1996 - 1998 by HyperAct, Inc.
// All Rights Reserved.
//
/////////////////////////////////////////////////////////////////////////////

// Defines :

//      wap_delphi
//      wap_cbuilder

//      wap_delphi_2
//      wap_delphi_3
//      wap_delphi_4

//      wap_cbuilder_1
//      wap_cbuilder_3

//      wap_delphi_2_or_cbuilder_1
//      wap_delphi_3_or_delphi_4
//      wap_delphi_3_or_cbuilder_3
//      wap_delphi_3_or_delphi_4_or_cbuilder_3

//      wap_need_TCollection_editor
//      wap_axscript

//////////////////////////////////////////////////////////////////////
//
// Basic version identification defines :
//
//////////////////////////////////////////////////////////////////////

{$ifdef ver90}
    {$define wap_delphi}
    {$define wap_delphi_2}
{$endif ver90}

{$ifdef ver93}
    {$define wap_cbuilder}
    {$define wap_cbuilder_1}
{$endif ver93}

{$ifdef ver100}
    {$define wap_delphi}
    {$define wap_delphi_3}
{$endif ver100}

{$ifdef ver110}
    {$define wap_cbuilder}
    {$define wap_cbuilder_3}
{$endif ver110}

{$ifdef ver120}
    {$define wap_delphi}
    {$define wap_delphi_4}
{$endif ver120}

//////////////////////////////////////////////////////////////////////
//
// Combined version identification defines :
//
//////////////////////////////////////////////////////////////////////

{$ifdef wap_delphi_2}
    {$define wap_delphi_2_or_cbuilder_1}
{$endif wap_delphi_2}

{$ifdef wap_cbuilder_1}
    {$define wap_delphi_2_or_cbuilder_1}
{$endif wap_cbuilder_1}

{$ifdef wap_delphi_3}
    {$define wap_delphi_3_or_delphi_4}
    {$define wap_delphi_3_or_delphi_4_or_cbuilder_3}
    {$define wap_delphi_3_or_cbuilder_3}
{$endif wap_delphi_3}

{$ifdef wap_delphi_4}
    {$define wap_delphi_3_or_delphi_4}
    {$define wap_delphi_3_or_delphi_4_or_cbuilder_3}
{$endif wap_delphi_4}

{$ifdef wap_cbuilder_3}
    {$define wap_delphi_3_or_delphi_4_or_cbuilder_3}
    {$define wap_delphi_3_or_cbuilder_3}
{$endif wap_cbuilder_3}

//////////////////////////////////////////////////////////////////////
//
// Toggle functionality by version :
//
//////////////////////////////////////////////////////////////////////

//
// Delphi 2 and CBuilder 1 did not have a built-in TCollection property
// editor, we need to supply our own.
// 
{$ifdef wap_delphi_2_or_cbuilder_1}
    {$define wap_need_TCollection_editor}
{$endif wap_delphi_2_or_cbuilder_1}

//
// ActiveX Scripting is not supported in Delphi 2 / CBuilder 1 due to
// their limited COM support. Enable it in all version of Delphi except for
// these two :
// 
{$ifndef wap_delphi_2_or_cbuilder_1}
    {$define wap_axscript}
{$endif wap_delphi_2_or_cbuilder_1}


