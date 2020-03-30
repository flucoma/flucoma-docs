/*
Part of the Fluid Corpus Manipulation Project (http://www.flucoma.org/)
Copyright 2017-2019 University of Huddersfield.
Licensed under the BSD-3 License.
See license.md file in the project root for full license information.
This project has received funding from the European Research Council (ERC)
under the European Union’s Horizon 2020 research and innovation programme
(grant agreement No 725899).
*/

#pragma once
#include <clients/common/FluidBaseClient.hpp>
#include <nlohmann/json.hpp>
#include <array>
#include <fstream>
#include <string>
#include <utility>


// for convenience
using json = nlohmann::json;

namespace fluid {
namespace client {

template <typename>
struct ParamOffsets;

template <typename Offsets, typename P>
struct ParamOffsets<const ParameterDescriptorSet<Offsets, P>>
{
  using OffsetList = Offsets;
};

template <typename C>
struct Constraint;

template <>
struct Constraint<EnumT::EnumConstraint>
{
  template <size_t Offset, typename Tuple>
  static json::object_t::value_type dump(const EnumT::EnumConstraint&, Tuple&)
  {
    return {"Enum", true};
  }
};

template <int MaxFFT>
struct Constraint<FFTParams::FFTSettingsConstraint<MaxFFT>>
{
  template <size_t Offset, typename Tuple>
  static json::object_t::value_type
  dump(const FFTParams::FFTSettingsConstraint<MaxFFT>&, Tuple&)
  {
    return {"MaxFFT", MaxFFT > -1};
  }
};


template <typename T>
struct Constraint<impl::MinImpl<T>>
{
  template <size_t Offset, typename Tuple>
  static json::object_t::value_type dump(const impl::MinImpl<T>& c, Tuple&)
  {
    return {"min", c.value};
  }
};

template <typename T>
struct Constraint<impl::MaxImpl<T>>
{
  template <size_t Offset, typename Tuple>
  static json::object_t::value_type dump(const impl::MaxImpl<T>& c, Tuple&)
  {
    return {"max", c.value};
  }
};

template <int... Is, typename Tuple>
std::array<const char*, sizeof...(Is)> relations(Tuple& params)
{
  return {{std::get<0>(std::get<Is>(params)).name...}};
}

template <int... Is>
struct Constraint<impl::UpperLimitImpl<Is...>>
{
  template <size_t Offset, typename Tuple>
  static json::object_t::value_type dump(const impl::UpperLimitImpl<Is...>&,
                                         Tuple& params)
  {
    return {"upper", relations<Offset + Is...>(params)};
  }
};

template <int... Is>
struct Constraint<impl::LowerLimitImpl<Is...>>
{
  template <size_t Offset, typename Tuple>
  static json::object_t::value_type dump(const impl::LowerLimitImpl<Is...>&,
                                         Tuple& params)
  {
    return {"lower", relations<Offset + Is...>(params)};
  }
};

template <int I>
struct Constraint<impl::FrameSizeUpperLimitImpl<I>>
{
  template <size_t Offset, typename Tuple>
  static json::object_t::value_type
  dump(const impl::FrameSizeUpperLimitImpl<I>&, Tuple&)
  {
    return {"upper", "fftFrame"};
  }
};

template <int I>
struct Constraint<impl::MaxFrameSizeUpperLimitImpl<I>>
{
  template <size_t Offset, typename Tuple>
  static json::object_t::value_type
  dump(const impl::MaxFrameSizeUpperLimitImpl<I>&, Tuple&)
  {
    return {"upper", "maxFFTFrame"};
  }
};


template <>
struct Constraint<Odd>
{
  template <size_t Offset, typename Tuple>
  static json::object_t::value_type dump(const Odd&, Tuple&)
  {
    return {"snap", "odd"};
  }
};

template <>
struct Constraint<PowerOfTwo>
{
  template <size_t Offset, typename Tuple>
  static json::object_t::value_type dump(const PowerOfTwo&, Tuple&)
  {
    return {"snap", "powerTwo"};
  }
};

template <>
struct Constraint<FrequencyAmpPairConstraint>
{
  template <size_t Offset, typename Tuple>
  static json::object_t::value_type dump(const FrequencyAmpPairConstraint&,
                                         Tuple&)
  {
    return {"FreqAmpPair", "true"};
  }
};

void to_json(json& j, const FFTParams& p)
{
  j = json::array({{"winSize", p.winSize()},
                   {"hopSize", p.hopRaw()},
                   {"fftSize", p.fftRaw()}});
}

void to_json(json& j, const FloatPairsArrayT::FloatPairsArrayType& p)
{
  j = json{{"value", p.value}};
}

template <template <typename> class T>
class ParameterDump
{
public:
  using Params = typename T<double>::ParamDescType;
  using Offsets = typename ParamOffsets<Params>::OffsetList;

  static void dump(std::string ofile, std::string prefix)
  {
    json j = dumpImpl(typename Params::IndexList(), Offsets{});
    //    std::string cwd(getcwd(nullptr,0));
    std::ofstream(prefix + ofile + ".json") << j.dump(2) << '\n';
  }

  template <size_t... Is, size_t... Offsets>
  static json dumpImpl(std::index_sequence<Is...>,
                       std::index_sequence<Offsets...>)
  {
    Params& p = T<double>::getParameterDescriptors();

    json j = json::array({jsonify<std::get<Is>(std::make_tuple(Offsets...))>(
        std::get<Is>(p.descriptors()), p.descriptors())...});
    return j;
  }

  template <size_t Offset, size_t... Is, typename C, typename P>
  static json constraints(const C& constraints, std::index_sequence<Is...>,
                          P&       allParams)
  {
    json res = json::object();
    (void) std::initializer_list<int>{(
        res.push_back(
            Constraint<typename std::tuple_element<Is, C>::type>::template dump<
                Offset>(std::get<Is>(constraints), allParams)),
        0)...};
    return res;
  }

  template <size_t Offset, typename P, typename All>
  static json::object_t::value_type jsonify(P& param, All& allParams)
  {

    return jsonify_param<Offset>(std::get<0>(param), param, allParams);
  }

  static std::string getParamType(const BufferT&) { return "buffer"; }
  static std::string getParamType(const InputBufferT&) { return "buffer"; }
  static std::string getParamType(const FloatT&) { return "float"; }
  static std::string getParamType(const LongT&) { return "long"; }
  static std::string getParamType(const FloatPairsArrayT&) { return "float"; }

  template <size_t Offset, typename P, typename Tuple, typename All>
  static json::object_t::value_type jsonify_param(P& p, Tuple& tuple,
                                                  All& allParams)
  {
    constexpr bool fixed = std::tuple_element<2, Tuple>::type::value;
    json           j;
    j["displayName"] = p.displayName;
    j["default"] = p.defaultValue;
    j["fixed"] = fixed;
    j["type"] = getParamType(p);
    j["size"] = p.fixedSize;

    auto& constraintsTuple = std::get<1>(tuple);
    using constraintsTupleType = std::decay_t<decltype(constraintsTuple)>;
    constexpr size_t numConstraints =
        std::tuple_size<constraintsTupleType>::value;
    if (numConstraints > 0)
    {
      auto constraintsIndex = std::make_index_sequence<numConstraints>();
      auto c =
          constraints<Offset>(constraintsTuple, constraintsIndex, allParams);
      if (c.type() != json::value_t::null) j["constraints"] = c;
    }
    
    return {p.name, j};
  }


  template <size_t, typename Tuple, typename All>
  static json::object_t::value_type jsonify_param(const EnumT& p, Tuple&, All&)
  {
    json j;
    j["displayName"] = p.displayName;
    j["default"] = p.defaultValue;
    j["fixed"] = false;
    j["size"] = 1;
    std::vector<std::string> strings(p.numOptions);
    std::copy(p.strings, p.strings + p.numOptions, strings.begin());
    j["values"] = strings;
    j["type"] = "enum";
    return {p.name, j};
  }

  template <size_t, typename Tuple, typename All>
  static json::object_t::value_type jsonify_param(const FFTParamsT& p, Tuple&,
                                                  All&)
  {
    json j;
    j["displayName"] = p.displayName;
    j["default"] = p.defaultValue;
    j["fixed"] = false;
    j["size"] = 3;
    j["type"] = "long";
    return {p.name, j};
  }
};
} // namespace client
} // namespace fluid
